import 'package:showscape/features/event_detail/domain/models/mock_review.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// Provides top 20 verified mock reviews for any event
class MockReviewsData {
  const MockReviewsData._();

  /// Returns exactly 20 mock reviews for [event]
  static List<MockReview> getTop20Reviews(Event event) {
    final title = event.title;
    final lead = event.cast.isNotEmpty ? event.cast.first : 'The lead cast';
    final secondLead =
        event.cast.length > 1 ? event.cast[1] : 'supporting actors';
    final isComedy =
        event.type == EventType.comedy || event.genres.contains('Comedy');
    final isConcert =
        event.type == EventType.concert || event.genres.contains('Music');
    final isSports = event.type == EventType.sports;

    final List<Map<String, dynamic>> templates;

    if (isComedy) {
      templates = [
        {
          'author': 'Aarav Mehta',
          'rating': 9.5,
          'text':
              'Non-stop laughs from the first minute to the closing punchline! $lead delivers pure comic timing.',
          'tags': ['Punchlines', 'Relatable', 'Timing']
        },
        {
          'author': 'Priya Deshmukh',
          'rating': 9.0,
          'text':
              'The crowd interaction was phenomenal. Totally fresh observational material with unforced humor.',
          'tags': ['Crowd Work', 'Observational', 'Hilarious']
        },
        {
          'author': 'Karan Malhotra',
          'rating': 8.5,
          'text':
              'Loved how effortlessly the anecdotes connected with city life. Stomach hurt from laughing so much!',
          'tags': ['City Life', 'Anecdotes', 'Laughs']
        },
        {
          'author': 'Simran Kaur',
          'rating': 9.5,
          'text':
              'Perfect evening out with friends. High-energy performance that stayed crisp and engaging throughout.',
          'tags': ['Energy', 'High-Spirited', 'Must-Watch']
        },
        {
          'author': 'Rohan Varma',
          'rating': 8.0,
          'text':
              'Extremely relatable bits on relationships and work culture. The second half was especially sharp.',
          'tags': ['Relatable', 'Sharp', 'Witty']
        },
        {
          'author': 'Ananya Roy',
          'rating': 9.0,
          'text':
              'A masterclass in modern stand-up. Improv moments had the entire hall roaring in laughter.',
          'tags': ['Improv', 'Masterclass', 'Crowd Roar']
        },
        {
          'author': 'Vikramaditya Rao',
          'rating': 8.5,
          'text':
              'Top notch venue acoustics and flawless delivery. Great pacing with no dull moments.',
          'tags': ['Pacing', 'Acoustics', 'Flawless']
        },
        {
          'author': 'Sneha Kulkarni',
          'rating': 9.0,
          'text':
              'Honest, witty, and surprisingly heartfelt in parts. Left the auditorium in high spirits.',
          'tags': ['Heartfelt', 'Witty', 'Vibe']
        },
        {
          'author': 'Devendra Singh',
          'rating': 8.5,
          'text':
              'Original jokes with brilliant setup-payoff structure. Worth every single penny of the ticket.',
          'tags': ['Original', 'Worth It', 'Value']
        },
        {
          'author': 'Tanvi Shah',
          'rating': 9.5,
          'text':
              'The best live stand-up set I have witnessed this year. A refreshing laugh riot for the weekend.',
          'tags': ['Laugh Riot', 'Top Tier', 'Weekend']
        },
        {
          'author': 'Aditya Joshi',
          'rating': 8.0,
          'text':
              'Clean, clever humor that resonates across age brackets. Great stage presence and charisma.',
          'tags': ['Clever', 'Charisma', 'Presence']
        },
        {
          'author': 'Meera Nambiar',
          'rating': 9.0,
          'text':
              'Unstoppable banter and incredible confidence on stage. Had our entire row in stitches.',
          'tags': ['Banter', 'Confidence', 'In Stitches']
        },
        {
          'author': 'Varun Gupta',
          'rating': 8.5,
          'text':
              'Very natural flow with no awkward transitions. Even the opening act set a fantastic mood.',
          'tags': ['Flow', 'Opening Act', 'Mood']
        },
        {
          'author': 'Ishita Sen',
          'rating': 9.0,
          'text':
              'Spontaneous and genuinely funny. Loved the localized cultural references thrown in.',
          'tags': ['Spontaneous', 'Cultural', 'Fun']
        },
        {
          'author': 'Nikhil Nair',
          'rating': 8.0,
          'text':
              'Smart writing that avoids clichés. The closing punchline tied the entire set together.',
          'tags': ['Smart Writing', 'Climax', 'Crisp']
        },
        {
          'author': 'Pooja Bhattacharya',
          'rating': 9.5,
          'text':
              'Electric vibe in the audience! You could feel everyone unwinding and having a blast.',
          'tags': ['Electric Vibe', 'Unwind', 'Fun']
        },
        {
          'author': 'Siddharth Saxena',
          'rating': 8.5,
          'text':
              'Super interactive with the front rows without being mean. Great warm-hearted comedic spirit.',
          'tags': ['Interactive', 'Warm', 'Humor']
        },
        {
          'author': 'Ritu Trivedi',
          'rating': 9.0,
          'text':
              'Laughed until my mascara ran! Definitely recommending $title to all my family and colleagues.',
          'tags': ['Hilarious', 'Recommended', 'Joy']
        },
        {
          'author': 'Gaurav Chopra',
          'rating': 8.5,
          'text':
              'Fast-paced, sharp wit with zero filler. One of the tightest 75 minutes of live comedy.',
          'tags': ['Fast-Paced', 'Zero Filler', 'Tight']
        },
        {
          'author': 'Kavita Das',
          'rating': 9.0,
          'text':
              'Pure joy and relief after a stressful work week. Authentic humor at its finest.',
          'tags': ['Pure Joy', 'Relief', 'Authentic']
        },
      ];
    } else if (isConcert) {
      templates = [
        {
          'author': 'Kabir Sehgal',
          'rating': 10.0,
          'text':
              'An unearthly sensory experience! The live vocals and acoustic solos gave me goosebumps for two straight hours.',
          'tags': ['Sensory', 'Goosebumps', 'Acoustic']
        },
        {
          'author': 'Natasha Parekh',
          'rating': 9.5,
          'text':
              'Stadium energy was off the charts. The synchronized LED wristband lights created a surreal galaxy effect.',
          'tags': ['Stadium Energy', 'Lights', 'Surreal']
        },
        {
          'author': 'Arjun Nanda',
          'rating': 9.0,
          'text':
              'Flawless sound engineering even in the upper tiers. The bass drops reverberated through the venue perfectly.',
          'tags': ['Sound Engineering', 'Bass', 'Acoustics']
        },
        {
          'author': 'Radhika Menon',
          'rating': 9.5,
          'text':
              'A dream setlist mixing historic fan favorites with explosive new track arrangements. Absolutely unforgettable.',
          'tags': ['Setlist', 'Fan Favorites', 'Unforgettable']
        },
        {
          'author': 'Farhan Qureshi',
          'rating': 9.0,
          'text':
              'Pure musical mastery. The live band transitions and drum solos elevated the entire concert experience.',
          'tags': ['Live Band', 'Drum Solos', 'Mastery']
        },
        {
          'author': 'Zoya Merchant',
          'rating': 10.0,
          'text':
              'Sang along to every single lyric with 40,000 strangers. An emotional, soul-stirring live night.',
          'tags': ['Singalong', 'Soul-Stirring', 'Emotional']
        },
        {
          'author': 'Manish Kothari',
          'rating': 8.5,
          'text':
              'Stage pyrotechnics and visual storytelling on the giant LED monoliths were world-class.',
          'tags': ['Pyrotechnics', 'Visuals', 'World-Class']
        },
        {
          'author': 'Divya Pillai',
          'rating': 9.5,
          'text':
              'The encore performance of their greatest anthem was worth the entire ticket price alone.',
          'tags': ['Encore', 'Anthem', 'Value']
        },
        {
          'author': 'Sameer Alva',
          'rating': 9.0,
          'text':
              'Incredible stage presence and stamina. Never let the tempo drop for a single second.',
          'tags': ['Stamina', 'Presence', 'Tempo']
        },
        {
          'author': 'Bhavna Jha',
          'rating': 9.5,
          'text':
              'The acoustic segment in the middle brought quiet tears to half the audience. Soulful and raw.',
          'tags': ['Acoustic', 'Soulful', 'Raw']
        },
        {
          'author': 'Harshvardhan Jain',
          'rating': 8.5,
          'text':
              'High-grade concert production. Seamless crowd management and crisp spatial audio setup.',
          'tags': ['Production', 'Crowd Vibe', 'Audio']
        },
        {
          'author': 'Tanya Singhal',
          'rating': 9.0,
          'text':
              'Vocal clarity was mind-blowing despite the sheer volume of the arena. Highly disciplined music.',
          'tags': ['Vocal Clarity', 'Arena', 'Disciplined']
        },
        {
          'author': 'Kunal Bajaj',
          'rating': 9.5,
          'text':
              'The crowd unison during the choruses was deafening in the best way possible. Unmatched atmosphere.',
          'tags': ['Crowd Unison', 'Atmosphere', 'Chorus']
        },
        {
          'author': 'Ayesha Kapoor',
          'rating': 9.0,
          'text':
              'Visually stunning laser choreography synced right on the beat. A festival-grade spectacle.',
          'tags': ['Lasers', 'Choreography', 'Spectacle']
        },
        {
          'author': 'Pranav Somani',
          'rating': 8.5,
          'text':
              'Great balance between high-octane rock numbers and tender introspective ballads.',
          'tags': ['Balance', 'Rock', 'Ballads']
        },
        {
          'author': 'Shreya Mathur',
          'rating': 9.5,
          'text':
              'One of those nights that will stay etched in memory for decades. Worth every bit of the hype.',
          'tags': ['Memorable', 'Hype', 'Top Tier']
        },
        {
          'author': 'Rahul Chawla',
          'rating': 9.0,
          'text':
              'The chemistry between the artists on stage was infectious. Truly passionate music lovers.',
          'tags': ['Chemistry', 'Passion', 'Live']
        },
        {
          'author': 'Deepika Soni',
          'rating': 9.5,
          'text':
              'Electric from start to finish. Heartfelt speeches between tracks made the stadium feel intimate.',
          'tags': ['Intimate', 'Electric', 'Heartfelt']
        },
        {
          'author': 'Akash Reddy',
          'rating': 8.5,
          'text':
              'Sound mixers nailed the live frequency balance. Vocals cut through the heavy synth bass with zero distortion.',
          'tags': ['Frequency', 'Zero Distortion', 'Sound']
        },
        {
          'author': 'Monika Sharma',
          'rating': 10.0,
          'text':
              'Pure euphoria. If $title performs again in this city, buying tickets on day one without hesitation.',
          'tags': ['Euphoria', 'Must-Attend', '10/10']
        },
      ];
    } else if (isSports) {
      templates = [
        {
          'author': 'Vijay Raghavan',
          'rating': 9.5,
          'text':
              'High-octane stadium drama! The nail-biting final moments had every spectator on their feet screaming.',
          'tags': ['Nail-Biting', 'Stadium Drama', 'Thrilling']
        },
        {
          'author': 'Sanjay Hegde',
          'rating': 9.0,
          'text':
              'Electrifying atmosphere with passionate rival fan chants echoing across all stands.',
          'tags': ['Rivalry', 'Fan Chants', 'Atmosphere']
        },
        {
          'author': 'Tarun Bedi',
          'rating': 8.5,
          'text':
              'World-class athleticism and tactical masterclass on full display under the floodlights.',
          'tags': ['Athleticism', 'Tactics', 'Floodlights']
        },
        {
          'author': 'Neha Oberoi',
          'rating': 9.5,
          'text':
              'Unbelievable turnaround in the second half. Sports entertainment at its very zenith.',
          'tags': ['Turnaround', 'Zenith', 'Excitement']
        },
        {
          'author': 'Abhinav Tyagi',
          'rating': 9.0,
          'text':
              'Great sightlines from the pavilion and deafening roar when the match-winning point was scored.',
          'tags': ['Sightlines', 'Roar', 'Match-Winning']
        },
        {
          'author': 'Pallavi Sood',
          'rating': 8.5,
          'text':
              'Intense end-to-end action with zero letup in pace. An adrenaline-pumping weekend fixture.',
          'tags': ['Adrenaline', 'End-to-End', 'Action']
        },
        {
          'author': 'Kartik Nair',
          'rating': 9.0,
          'text':
              'Superb venue amenities and giant replay screens made every controversial call crystal clear.',
          'tags': ['Replay Screens', 'Amenities', 'Clarity']
        },
        {
          'author': 'Geeta Krishnan',
          'rating': 9.5,
          'text':
              'Watching the captain lead from the front was inspiring. Pure sporting brilliance.',
          'tags': ['Captaincy', 'Brilliance', 'Inspiring']
        },
        {
          'author': 'Suresh Kamath',
          'rating': 8.0,
          'text':
              'Defensive discipline was extraordinary, setting up thunderous counter-attacks.',
          'tags': ['Defense', 'Counters', 'Discipline']
        },
        {
          'author': 'Alok Pandey',
          'rating': 9.0,
          'text':
              'Unmatched camaraderie in the stands. Cheering together with thousands of passionate fans.',
          'tags': ['Camaraderie', 'Passion', 'Cheering']
        },
        {
          'author': 'Bhavin Patel',
          'rating': 9.5,
          'text':
              'The climactic minutes were sheer sporting magic. Heart was pounding in my chest.',
          'tags': ['Magic', 'Heart Pounding', 'Climax']
        },
        {
          'author': 'Smita Joshi',
          'rating': 8.5,
          'text':
              'High-grade athletic prowess. You appreciate the speed of the game so much more in person.',
          'tags': ['Prowess', 'Speed', 'Live View']
        },
        {
          'author': 'Girish Rao',
          'rating': 9.0,
          'text':
              'Fierce tactical battle that kept everyone guessing until the final whistle.',
          'tags': ['Tactical Battle', 'Suspense', 'Whistle']
        },
        {
          'author': 'Meenakshi Iyer',
          'rating': 9.5,
          'text':
              'Historic sporting moment witnessed live! Taking my kids here was the best decision ever.',
          'tags': ['Historic', 'Family', 'Unforgettable']
        },
        {
          'author': 'Rohit Bhardwaj',
          'rating': 8.5,
          'text':
              'Clean stadium facilities, rapid security check-in, and spectacular pitch-level view.',
          'tags': ['Pitch View', 'Facilities', 'Smooth']
        },
        {
          'author': 'Ankita Ghosh',
          'rating': 9.0,
          'text':
              'The team spirit and fighting resilience showed true champions pedigree.',
          'tags': ['Resilience', 'Team Spirit', 'Champions']
        },
        {
          'author': 'Praveen Varma',
          'rating': 9.5,
          'text':
              'Breathless energy from the opening minute. Stadium wave going around five consecutive times!',
          'tags': ['Stadium Wave', 'Breathless', 'Energy']
        },
        {
          'author': 'Jayesh Solanki',
          'rating': 8.5,
          'text':
              'Spectacular individual performances backed by rock-solid coaching strategy.',
          'tags': ['Individual Skill', 'Strategy', 'Solid']
        },
        {
          'author': 'Swati Mukherji',
          'rating': 9.0,
          'text':
              'A rollercoaster of emotions through every tense moment. Live sport has no equal.',
          'tags': ['Rollercoaster', 'Emotions', 'No Equal']
        },
        {
          'author': 'Dinesh Kulkarni',
          'rating': 9.5,
          'text':
              'The celebration at the final whistle gave everybody goosebumps. Absolute triumph.',
          'tags': ['Triumph', 'Goosebumps', 'Epic']
        },
      ];
    } else {
      // General Movie / Cinematic Event
      templates = [
        {
          'author': 'Aditya Rathi',
          'rating': 9.5,
          'text':
              '$lead delivers a career-defining performance with unshakeable screen presence and charisma.',
          'tags': ['Acting', 'Screen Presence', 'Leading Role']
        },
        {
          'author': 'Shruti Mahajan',
          'rating': 9.0,
          'text':
              'The interval block and high-stakes confrontation sequences give you absolute goosebumps in IMAX.',
          'tags': ['IMAX', 'Interval Twist', 'Goosebumps']
        },
        {
          'author': 'Vivek Subramanian',
          'rating': 8.5,
          'text':
              'Thumping background score and impeccable sound design elevate every single emotional beat.',
          'tags': ['BGM', 'Sound Design', 'Emotional Core']
        },
        {
          'author': 'Ananya Sengupta',
          'rating': 9.5,
          'text':
              'World-class cinematography and expansive world-building that stands tall against global cinema.',
          'tags': ['Cinematography', 'World Building', 'VFX']
        },
        {
          'author': 'Karthik Raja',
          'rating': 9.0,
          'text':
              'The dynamic between $lead and $secondLead crackles with fierce tension and magnetic chemistry.',
          'tags': ['Chemistry', 'Face-Off', 'Tension']
        },
        {
          'author': 'Preeti Agrawal',
          'rating': 8.5,
          'text':
              'Tight screenplay that rarely drags despite the ambitious runtime. Crisp editing throughout.',
          'tags': ['Screenplay', 'Pacing', 'Editing']
        },
        {
          'author': 'Rishi Tandon',
          'rating': 9.0,
          'text':
              'Action choreography is visceral, grounded yet larger than life. The theatre exploded into whistles.',
          'tags': ['Action', 'Choreography', 'Theatre Vibe']
        },
        {
          'author': 'Megha Sundaram',
          'rating': 9.5,
          'text':
              'A visual masterpiece with jaw-dropping set designs and thoughtful costume detailing.',
          'tags': ['Visuals', 'Set Design', 'Aesthetics']
        },
        {
          'author': 'Harish Patel',
          'rating': 8.0,
          'text':
              'Strong character motivations and memorable supporting arcs make the stakes genuinely matter.',
          'tags': ['Characters', 'Stakes', 'Depth']
        },
        {
          'author': 'Tanvi Malhotra',
          'rating': 9.5,
          'text':
              'Emotional payoff in the third act hits hard without turning melodramatic. Pure cinematic magic.',
          'tags': ['Emotional Payoff', 'Climax', 'Magic']
        },
        {
          'author': 'Gautam Nambisan',
          'rating': 8.5,
          'text':
              'Bold directorial vision backed by uncompromising technical polish. A theatrical must-watch.',
          'tags': ['Direction', 'Polish', 'Theatrical']
        },
        {
          'author': 'Nandini Joshi',
          'rating': 9.0,
          'text':
              'Every dialogue lands with immense punch. The auditorium was chanting along during key scenes.',
          'tags': ['Dialogues', 'Mass Moments', 'Chants']
        },
        {
          'author': 'Chetan Vohra',
          'rating': 8.5,
          'text':
              'VFX integration is remarkably seamless and artistic. Never feels artificial or hollow.',
          'tags': ['VFX', 'Seamless', 'Artistry']
        },
        {
          'author': 'Swara Kulkarni',
          'rating': 9.0,
          'text':
              'Balanced narrative that blends high adrenaline spectacle with heartfelt human sentiment.',
          'tags': ['Sentiment', 'Spectacle', 'Narrative']
        },
        {
          'author': 'Aakash Pillai',
          'rating': 8.0,
          'text':
              'Intense musical themes linger in your head long after leaving the cinema hall.',
          'tags': ['Theme Music', 'Haunting', 'Lingering']
        },
        {
          'author': 'Pallavi Deol',
          'rating': 9.5,
          'text':
              'The climax twist ties together every subtle clue planted in the first hour. Brilliant writing.',
          'tags': ['Writing', 'Climax Twist', 'Foreshadowing']
        },
        {
          'author': 'Manish Saxena',
          'rating': 8.5,
          'text':
              'Exquisite color grading and lighting palettes give $title an unmistakable grand atmosphere.',
          'tags': ['Color Grading', 'Lighting', 'Atmosphere']
        },
        {
          'author': 'Bhakti Trivedi',
          'rating': 9.0,
          'text':
              'Rare cinematic feat where expectations were sky high and the film still comfortably exceeded them.',
          'tags': ['Exceeded Hype', 'Blockbuster', 'Masterpiece']
        },
        {
          'author': 'Siddharth Kaul',
          'rating': 9.0,
          'text':
              'Exceptional stunt coordination and sound engineering. Deserves to be seen on the biggest screen.',
          'tags': ['Stunts', 'Big Screen', 'Engineering']
        },
        {
          'author': 'Rituja Barve',
          'rating': 9.5,
          'text':
              'A landmark achievement for modern storytelling that will be celebrated for years to come.',
          'tags': ['Landmark', 'Celebration', 'Triumph']
        },
      ];
    }

    final now = DateTime.now();
    return List.generate(20, (index) {
      final t = templates[index];
      return MockReview(
        id: 'rev_${event.id}_${index + 1}',
        eventId: event.id,
        authorName: t['author'] as String,
        rating: (t['rating'] as num).toDouble(),
        text: t['text'] as String,
        createdAt: now.subtract(Duration(hours: (index * 3) + 2)),
        tags: List<String>.from(t['tags'] as List),
      );
    });
  }
}
