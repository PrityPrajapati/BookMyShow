import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// 8-minute hold TTL in milliseconds
const HOLD_TTL_MS = 8 * 60 * 1000;

interface HoldSeatsRequest {
  showId: string;
  seatIds: string[];
  userId: string;
}

interface ConfirmBookingRequest {
  showId: string;
  holdId: string;
  seatIds: string[];
  userId: string;
  paymentId: string;
  eventId: string;
  venueId: string;
  priceBreakdown: any;
  fnbItems?: any[];
  parkingLot?: any;
}

/**
 * holdSeats: Atomically holds seats for 8 minutes using a Firestore transaction.
 */
export const holdSeats = functions.https.onCall(
  async (data: HoldSeatsRequest, context) => {
    const { showId, seatIds, userId } = data;

    if (!showId || !seatIds || !seatIds.length || !userId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "showId, seatIds, and userId are required."
      );
    }

    const showRef = db.collection("shows").doc(showId);
    const holdId = `hold_${Date.now()}_${userId}`;
    const holdRef = db.collection("seat_holds").doc(holdId);

    const result = await db.runTransaction(async (transaction) => {
      const showDoc = await transaction.get(showRef);
      if (!showDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Show not found.");
      }

      const now = Date.now();
      const expiresAt = now + HOLD_TTL_MS;

      // Verify that no requested seat is currently held or booked
      for (const seatId of seatIds) {
        const seatRef = showRef.collection("seats").doc(seatId);
        const seatDoc = await transaction.get(seatRef);

        if (seatDoc.exists) {
          const seatData = seatDoc.data() || {};
          const isBooked = seatData.state === "booked";
          const isCurrentlyHeld =
            seatData.state === "held" &&
            seatData.holdExpiresAt &&
            seatData.holdExpiresAt > now &&
            seatData.heldBy !== userId;

          if (isBooked || isCurrentlyHeld) {
            throw new functions.https.HttpsError(
              "already-exists",
              `Seat ${seatId} is no longer available.`
            );
          }
        }
      }

      // Mark seats as held in transaction
      for (const seatId of seatIds) {
        const seatRef = showRef.collection("seats").doc(seatId);
        transaction.set(
          seatRef,
          {
            state: "held",
            heldBy: userId,
            holdId: holdId,
            heldAt: admin.firestore.Timestamp.fromMillis(now),
            holdExpiresAt: admin.firestore.Timestamp.fromMillis(expiresAt),
          },
          { merge: true }
        );
      }

      // Create hold session document
      transaction.set(holdRef, {
        id: holdId,
        showId,
        seatIds,
        userId,
        createdAt: admin.firestore.Timestamp.fromMillis(now),
        expiresAt: admin.firestore.Timestamp.fromMillis(expiresAt),
        ttlMinutes: 8,
        status: "active",
      });

      return {
        holdId,
        expiresAt,
        ttlMinutes: 8,
        seatIds,
      };
    });

    return {
      success: true,
      message: "Seats held successfully for 8 minutes.",
      ...result,
    };
  }
);

/**
 * confirmBooking: Converts held seats to booked seats and creates the booking and tickets.
 */
export const confirmBooking = functions.https.onCall(
  async (data: ConfirmBookingRequest, context) => {
    const {
      showId,
      holdId,
      seatIds,
      userId,
      paymentId,
      eventId,
      venueId,
      priceBreakdown,
      fnbItems = [],
      parkingLot = null,
    } = data;

    if (!showId || !seatIds || !userId || !paymentId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required booking parameters."
      );
    }

    const showRef = db.collection("shows").doc(showId);
    const holdRef = db.collection("seat_holds").doc(holdId);
    const bookingId = `bkg_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const bookingRef = db.collection("bookings").doc(bookingId);

    const bookingResult = await db.runTransaction(async (transaction) => {
      const now = Date.now();

      // Verify hold validity
      const holdDoc = await transaction.get(holdRef);
      if (holdDoc.exists) {
        const holdData = holdDoc.data() || {};
        const holdExpiry = holdData.expiresAt?.toMillis?.() || holdData.expiresAt;
        if (holdExpiry && holdExpiry < now) {
          throw new functions.https.HttpsError(
            "deadline-exceeded",
            "Seat hold has expired. Please select seats again."
          );
        }
      }

      // Convert seats to booked status
      const tickets = [];
      for (let i = 0; i < seatIds.length; i++) {
        const seatId = seatIds[i];
        const seatRef = showRef.collection("seats").doc(seatId);

        transaction.set(
          seatRef,
          {
            state: "booked",
            bookedBy: userId,
            bookingId: bookingId,
            bookedAt: admin.firestore.Timestamp.fromMillis(now),
            holdExpiresAt: null,
            heldBy: null,
          },
          { merge: true }
        );

        const ticketId = `tkt_${bookingId}_${i + 1}`;
        tickets.push({
          id: ticketId,
          bookingId: bookingId,
          seatId: seatId,
          seatNumber: seatId,
          qrCodeData: `SHOWSCAPE:${bookingId}:${ticketId}:${seatId}`,
          status: "valid",
        });
      }

      // Mark hold as consumed
      if (holdDoc.exists) {
        transaction.update(holdRef, {
          status: "confirmed",
          bookingId: bookingId,
          confirmedAt: admin.firestore.Timestamp.fromMillis(now),
        });
      }

      // Create Booking record
      const bookingData = {
        id: bookingId,
        bookingNumber: `SS-${Date.now().toString().slice(-8)}`,
        userId,
        showId,
        eventId,
        venueId,
        paymentId,
        bookingTime: admin.firestore.Timestamp.fromMillis(now),
        tickets,
        fnbItems,
        parkingLot,
        priceBreakdown,
        status: "confirmed",
        qrCodeData: `SHOWSCAPE_BOOKING:${bookingId}`,
      };

      transaction.set(bookingRef, bookingData);

      return bookingData;
    });

    return {
      success: true,
      message: "Booking confirmed successfully.",
      booking: bookingResult,
    };
  }
);
