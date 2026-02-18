/// Tennis content library for Zenslam
/// 120+ sessions across 13 categories (12 technique + Winning section)
///
/// This data serves as seed content and can be synced to Supabase.
/// Duration guide: Quick 4-9 min, Standard 10-12 min, Deep 13-15 min

class TennisCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int sortOrder;
  final bool isWinningSection;

  const TennisCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.sortOrder,
    this.isWinningSection = false,
  });
}

class TennisSession {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final int durationMinutes;
  final bool isPremium;
  final int sortOrder;

  const TennisSession({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.durationMinutes,
    this.isPremium = false,
    required this.sortOrder,
  });
}

/// All 13 categories
const List<TennisCategory> tennisCategories = [
  TennisCategory(id: 'forehand', name: 'Forehand', description: 'Visualize perfect forehand technique and build confidence in every stroke', iconName: 'forehand', sortOrder: 1),
  TennisCategory(id: 'backhand', name: 'Backhand', description: 'Master your backhand through mental rehearsal and visualization', iconName: 'backhand', sortOrder: 2),
  TennisCategory(id: 'serve', name: 'Serve', description: 'Build a powerful, consistent serve through focused mental training', iconName: 'serve', sortOrder: 3),
  TennisCategory(id: 'volley', name: 'Volley', description: 'Sharpen your net game with visualization and reflex training', iconName: 'volley', sortOrder: 4),
  TennisCategory(id: 'drop_shot', name: 'Stop/Drop Shot', description: 'Develop touch and feel for delicate shots', iconName: 'drop_shot', sortOrder: 5),
  TennisCategory(id: 'footwork', name: 'Footwork & Movement', description: 'Enhance court coverage and movement fluidity', iconName: 'footwork', sortOrder: 6),
  TennisCategory(id: 'eyes_on_ball', name: 'Eyes on the Ball', description: 'Train laser focus on ball tracking and contact point', iconName: 'eyes', sortOrder: 7),
  TennisCategory(id: 'confidence', name: 'Confidence & Self-Belief', description: 'Build unshakeable confidence on the court', iconName: 'confidence', sortOrder: 8),
  TennisCategory(id: 'focus', name: 'Concentration & Focus', description: 'Develop match-long mental focus and concentration', iconName: 'focus', sortOrder: 9),
  TennisCategory(id: 'flow_state', name: 'Flow State & Rhythm', description: 'Access the zone and play effortless tennis', iconName: 'flow', sortOrder: 10),
  TennisCategory(id: 'inner_game', name: 'Trusting Your Inner Game', description: 'Trust your instincts and play with freedom', iconName: 'inner_game', sortOrder: 11),
  TennisCategory(id: 'critical_moments', name: 'Critical Moments', description: 'Perform under pressure in the biggest moments', iconName: 'critical', sortOrder: 12),
  TennisCategory(id: 'winning', name: 'Winning', description: 'Complete mental toolkit for winning tennis', iconName: 'winning', sortOrder: 13, isWinningSection: true),
];

/// All 130 sessions
const List<TennisSession> tennisSessions = [
  // ── FOREHAND (12 sessions) ────────────────────────────────────────────
  TennisSession(id: 'fh01', title: 'Perfect Forehand Flow', description: 'Visualize your ideal forehand motion from preparation to follow-through', categoryId: 'forehand', durationMinutes: 10, sortOrder: 1),
  TennisSession(id: 'fh02', title: 'Forehand Winner Visualization', description: 'See yourself hitting powerful, precise forehand winners', categoryId: 'forehand', durationMinutes: 8, sortOrder: 2),
  TennisSession(id: 'fh03', title: 'Cross-Court Control', description: 'Build consistency and control on cross-court forehand rallies', categoryId: 'forehand', durationMinutes: 11, isPremium: true, sortOrder: 3),
  TennisSession(id: 'fh04', title: 'Forehand Under Pressure', description: 'Stay composed and execute your forehand in high-pressure points', categoryId: 'forehand', durationMinutes: 12, isPremium: true, sortOrder: 4),
  TennisSession(id: 'fh05', title: 'Inside-Out Forehand', description: 'Visualize the aggressive inside-out forehand to dominate rallies', categoryId: 'forehand', durationMinutes: 9, isPremium: true, sortOrder: 5),
  TennisSession(id: 'fh06', title: 'Passing Shot Mastery', description: 'See yourself threading forehand passing shots past the net player', categoryId: 'forehand', durationMinutes: 10, isPremium: true, sortOrder: 6),
  TennisSession(id: 'fh07', title: 'Heavy Topspin Forehand', description: 'Feel the brush and rotation of a heavy topspin forehand', categoryId: 'forehand', durationMinutes: 8, isPremium: true, sortOrder: 7),
  TennisSession(id: 'fh08', title: 'Flat Power Forehand', description: 'Visualize driving through the ball with flat, penetrating power', categoryId: 'forehand', durationMinutes: 7, sortOrder: 8),
  TennisSession(id: 'fh09', title: 'Short Ball Attack', description: 'React and attack short balls with decisive forehand aggression', categoryId: 'forehand', durationMinutes: 9, isPremium: true, sortOrder: 9),
  TennisSession(id: 'fh10', title: 'Running Forehand', description: 'Maintain balance and power on wide running forehands', categoryId: 'forehand', durationMinutes: 10, isPremium: true, sortOrder: 10),
  TennisSession(id: 'fh11', title: 'Return of Serve Forehand', description: 'Prepare mentally to return serve with a confident forehand', categoryId: 'forehand', durationMinutes: 11, isPremium: true, sortOrder: 11),
  TennisSession(id: 'fh12', title: 'Forehand Rhythm and Timing', description: 'Find your natural rhythm and perfect timing on every forehand', categoryId: 'forehand', durationMinutes: 12, isPremium: true, sortOrder: 12),

  // ── BACKHAND (12 sessions) ────────────────────────────────────────────
  TennisSession(id: 'bh01', title: 'Backhand Breakthrough', description: 'Transform your backhand from weakness to weapon', categoryId: 'backhand', durationMinutes: 11, sortOrder: 1),
  TennisSession(id: 'bh02', title: 'Two-Handed Power', description: 'Build power and confidence in your two-handed backhand', categoryId: 'backhand', durationMinutes: 10, sortOrder: 2),
  TennisSession(id: 'bh03', title: 'One-Handed Elegance', description: 'Develop a fluid, elegant one-handed backhand', categoryId: 'backhand', durationMinutes: 10, isPremium: true, sortOrder: 3),
  TennisSession(id: 'bh04', title: 'Down-the-Line Backhand', description: 'Visualize threading backhands down the line with precision', categoryId: 'backhand', durationMinutes: 9, isPremium: true, sortOrder: 4),
  TennisSession(id: 'bh05', title: 'Slice Mastery', description: 'Develop a penetrating, low-skidding backhand slice', categoryId: 'backhand', durationMinutes: 8, isPremium: true, sortOrder: 5),
  TennisSession(id: 'bh06', title: 'Defensive Slice', description: 'Use the slice to neutralize and buy time under pressure', categoryId: 'backhand', durationMinutes: 7, sortOrder: 6),
  TennisSession(id: 'bh07', title: 'High Backhand', description: 'Handle high-bouncing balls with confidence on the backhand', categoryId: 'backhand', durationMinutes: 9, isPremium: true, sortOrder: 7),
  TennisSession(id: 'bh08', title: 'Cross-Court Rally', description: 'Build consistency and depth on cross-court backhand exchanges', categoryId: 'backhand', durationMinutes: 11, isPremium: true, sortOrder: 8),
  TennisSession(id: 'bh09', title: 'Slice Approach Shot', description: 'Approach the net with a well-disguised slice', categoryId: 'backhand', durationMinutes: 8, isPremium: true, sortOrder: 9),
  TennisSession(id: 'bh10', title: 'Return Aggression', description: 'Attack the return of serve with a bold backhand', categoryId: 'backhand', durationMinutes: 10, isPremium: true, sortOrder: 10),
  TennisSession(id: 'bh11', title: 'Backhand Under Pressure', description: 'Stay solid on your backhand in the biggest moments', categoryId: 'backhand', durationMinutes: 12, isPremium: true, sortOrder: 11),
  TennisSession(id: 'bh12', title: 'Slice Drop Shot', description: 'Disguise and execute the perfect drop shot from the backhand', categoryId: 'backhand', durationMinutes: 7, isPremium: true, sortOrder: 12),

  // ── SERVE (10 sessions) ───────────────────────────────────────────────
  TennisSession(id: 'sv01', title: 'Ace Visualization', description: 'See yourself hitting aces with power and placement', categoryId: 'serve', durationMinutes: 10, sortOrder: 1),
  TennisSession(id: 'sv02', title: 'First Serve Power', description: 'Build confidence and power on your first serve', categoryId: 'serve', durationMinutes: 11, sortOrder: 2),
  TennisSession(id: 'sv03', title: 'Second Serve Confidence', description: 'Eliminate double fault anxiety with unshakeable second serve belief', categoryId: 'serve', durationMinutes: 12, isPremium: true, sortOrder: 3),
  TennisSession(id: 'sv04', title: 'Serve Under Pressure', description: 'Deliver your best serves in the most critical moments', categoryId: 'serve', durationMinutes: 13, isPremium: true, sortOrder: 4),
  TennisSession(id: 'sv05', title: 'Wide Serve Placement', description: 'Visualize pulling opponents wide with precise serve placement', categoryId: 'serve', durationMinutes: 9, isPremium: true, sortOrder: 5),
  TennisSession(id: 'sv06', title: 'Body Serve', description: 'Jam opponents with well-placed body serves', categoryId: 'serve', durationMinutes: 8, isPremium: true, sortOrder: 6),
  TennisSession(id: 'sv07', title: 'Kick Serve Mastery', description: 'Feel the snap and bounce of a devastating kick serve', categoryId: 'serve', durationMinutes: 10, isPremium: true, sortOrder: 7),
  TennisSession(id: 'sv08', title: 'Serve and Volley', description: 'Combine serve and net approach for aggressive play', categoryId: 'serve', durationMinutes: 11, isPremium: true, sortOrder: 8),
  TennisSession(id: 'sv09', title: 'Break Point Serving', description: 'Hold serve when it matters most — saving break points', categoryId: 'serve', durationMinutes: 12, isPremium: true, sortOrder: 9),
  TennisSession(id: 'sv10', title: 'Serving Rhythm', description: 'Find your natural service rhythm and pre-serve routine', categoryId: 'serve', durationMinutes: 9, sortOrder: 10),

  // ── VOLLEY (8 sessions) ───────────────────────────────────────────────
  TennisSession(id: 'vl01', title: 'Net Attack Visualization', description: 'See yourself dominating at the net with crisp volleys', categoryId: 'volley', durationMinutes: 10, sortOrder: 1),
  TennisSession(id: 'vl02', title: 'Reflex Volley', description: 'Sharpen your reflexes for quick exchanges at the net', categoryId: 'volley', durationMinutes: 8, sortOrder: 2),
  TennisSession(id: 'vl03', title: 'Approach and Finish', description: 'Approach the net with purpose and put away the volley', categoryId: 'volley', durationMinutes: 10, isPremium: true, sortOrder: 3),
  TennisSession(id: 'vl04', title: 'Low Volley Control', description: 'Handle low volleys with soft hands and precision', categoryId: 'volley', durationMinutes: 9, isPremium: true, sortOrder: 4),
  TennisSession(id: 'vl05', title: 'Overhead Smash', description: 'Visualize crushing overheads with authority', categoryId: 'volley', durationMinutes: 7, isPremium: true, sortOrder: 5),
  TennisSession(id: 'vl06', title: 'Touch Volley', description: 'Develop delicate touch on drop volleys and angle volleys', categoryId: 'volley', durationMinutes: 8, isPremium: true, sortOrder: 6),
  TennisSession(id: 'vl07', title: 'Volley Under Pressure', description: 'Stay calm and execute at the net in tight moments', categoryId: 'volley', durationMinutes: 11, isPremium: true, sortOrder: 7),
  TennisSession(id: 'vl08', title: 'Doubles Net Domination', description: 'Dominate the net in doubles with aggressive positioning', categoryId: 'volley', durationMinutes: 12, isPremium: true, sortOrder: 8),

  // ── STOP/DROP SHOT (6 sessions) ───────────────────────────────────────
  TennisSession(id: 'ds01', title: 'Drop Shot Perfection', description: 'Visualize the perfect drop shot with dead weight and backspin', categoryId: 'drop_shot', durationMinutes: 8, sortOrder: 1),
  TennisSession(id: 'ds02', title: 'Stop Shot Surprise', description: 'Catch your opponent off guard with a well-timed stop shot', categoryId: 'drop_shot', durationMinutes: 7, sortOrder: 2),
  TennisSession(id: 'ds03', title: 'Disguised Drop Shot', description: 'Hide your intentions until the last moment', categoryId: 'drop_shot', durationMinutes: 9, isPremium: true, sortOrder: 3),
  TennisSession(id: 'ds04', title: 'Drop Shot Defense', description: 'Recover and respond when opponents play drop shots against you', categoryId: 'drop_shot', durationMinutes: 8, isPremium: true, sortOrder: 4),
  TennisSession(id: 'ds05', title: 'Touch and Feel', description: 'Develop soft hands and delicate touch for short game', categoryId: 'drop_shot', durationMinutes: 10, isPremium: true, sortOrder: 5),
  TennisSession(id: 'ds06', title: 'Drop Shot Timing', description: 'Know exactly when to play the drop shot for maximum effect', categoryId: 'drop_shot', durationMinutes: 7, isPremium: true, sortOrder: 6),

  // ── FOOTWORK & MOVEMENT (8 sessions) ──────────────────────────────────
  TennisSession(id: 'fw01', title: 'Court Coverage', description: 'Visualize covering every inch of the court with efficient movement', categoryId: 'footwork', durationMinutes: 11, sortOrder: 1),
  TennisSession(id: 'fw02', title: 'Lightning Footwork', description: 'Train quick, light feet for explosive movement', categoryId: 'footwork', durationMinutes: 9, sortOrder: 2),
  TennisSession(id: 'fw03', title: 'Recovery Step', description: 'Master the recovery step to get back in position after every shot', categoryId: 'footwork', durationMinutes: 8, isPremium: true, sortOrder: 3),
  TennisSession(id: 'fw04', title: 'Split Step Mastery', description: 'Perfect your split step timing for optimal reaction', categoryId: 'footwork', durationMinutes: 7, isPremium: true, sortOrder: 4),
  TennisSession(id: 'fw05', title: 'Wide Ball Retrieval', description: 'Reach wide balls with explosive lateral movement', categoryId: 'footwork', durationMinutes: 10, isPremium: true, sortOrder: 5),
  TennisSession(id: 'fw06', title: 'Forward & Backward', description: 'Move fluidly forward and backward to handle depth changes', categoryId: 'footwork', durationMinutes: 9, isPremium: true, sortOrder: 6),
  TennisSession(id: 'fw07', title: 'Movement Flow', description: 'Achieve effortless, flowing movement patterns on court', categoryId: 'footwork', durationMinutes: 12, isPremium: true, sortOrder: 7),
  TennisSession(id: 'fw08', title: 'Sliding on Clay', description: 'Visualize confident sliding movement on clay courts', categoryId: 'footwork', durationMinutes: 8, isPremium: true, sortOrder: 8),

  // ── EYES ON THE BALL (6 sessions) ─────────────────────────────────────
  TennisSession(id: 'eb01', title: 'Ball Focus Meditation', description: 'Train your eyes to track the ball from opponent racket to yours', categoryId: 'eyes_on_ball', durationMinutes: 10, sortOrder: 1),
  TennisSession(id: 'eb02', title: 'Contact Point Visualization', description: 'See the ball at the exact point of contact with clarity', categoryId: 'eyes_on_ball', durationMinutes: 8, sortOrder: 2),
  TennisSession(id: 'eb03', title: 'Ball Tracking', description: 'Follow the ball through its entire flight path with sharp focus', categoryId: 'eyes_on_ball', durationMinutes: 9, isPremium: true, sortOrder: 3),
  TennisSession(id: 'eb04', title: 'Early Ball Recognition', description: 'Read the ball off your opponent racket sooner', categoryId: 'eyes_on_ball', durationMinutes: 11, isPremium: true, sortOrder: 4),
  TennisSession(id: 'eb05', title: 'Focus Through Contact', description: 'Maintain visual focus through the moment of contact', categoryId: 'eyes_on_ball', durationMinutes: 7, isPremium: true, sortOrder: 5),
  TennisSession(id: 'eb06', title: 'Watching Discipline', description: 'Build the discipline to keep your head still and eyes locked', categoryId: 'eyes_on_ball', durationMinutes: 8, isPremium: true, sortOrder: 6),

  // ── CONFIDENCE & SELF-BELIEF (12 sessions) ────────────────────────────
  TennisSession(id: 'cf01', title: 'Unshakeable Confidence', description: 'Build deep, lasting confidence that carries through every match', categoryId: 'confidence', durationMinutes: 12, sortOrder: 1),
  TennisSession(id: 'cf02', title: 'Champion Mindset', description: 'Develop the mental habits of a champion tennis player', categoryId: 'confidence', durationMinutes: 14, sortOrder: 2),
  TennisSession(id: 'cf03', title: 'Court Presence', description: 'Walk onto any court with commanding presence and authority', categoryId: 'confidence', durationMinutes: 10, isPremium: true, sortOrder: 3),
  TennisSession(id: 'cf04', title: 'Fearless Tennis', description: 'Play without fear of failure — go for your shots', categoryId: 'confidence', durationMinutes: 11, isPremium: true, sortOrder: 4),
  TennisSession(id: 'cf05', title: 'Permission to Dominate', description: 'Give yourself permission to play aggressively and dominate', categoryId: 'confidence', durationMinutes: 9, isPremium: true, sortOrder: 5),
  TennisSession(id: 'cf06', title: 'Big Match Belief', description: 'Believe in yourself for the biggest matches of your life', categoryId: 'confidence', durationMinutes: 13, isPremium: true, sortOrder: 6),
  TennisSession(id: 'cf07', title: 'Body Language Power', description: 'Use powerful body language to boost confidence and intimidate', categoryId: 'confidence', durationMinutes: 8, isPremium: true, sortOrder: 7),
  TennisSession(id: 'cf08', title: 'Belief After Setbacks', description: 'Rebuild confidence quickly after losses or poor performances', categoryId: 'confidence', durationMinutes: 12, isPremium: true, sortOrder: 8),
  TennisSession(id: 'cf09', title: 'Pre-Match Confidence', description: 'A pre-match confidence ritual for optimal readiness', categoryId: 'confidence', durationMinutes: 7, sortOrder: 9),
  TennisSession(id: 'cf10', title: 'Inner Champion', description: 'Connect with the champion that already exists inside you', categoryId: 'confidence', durationMinutes: 15, isPremium: true, sortOrder: 10),
  TennisSession(id: 'cf11', title: 'Natural Athlete', description: 'Reconnect with your natural athletic ability and talent', categoryId: 'confidence', durationMinutes: 10, isPremium: true, sortOrder: 11),
  TennisSession(id: 'cf12', title: 'Deserve to Win', description: 'Deeply believe that you deserve to win and succeed', categoryId: 'confidence', durationMinutes: 11, isPremium: true, sortOrder: 12),

  // ── CONCENTRATION & FOCUS (10 sessions) ───────────────────────────────
  TennisSession(id: 'fc01', title: 'Laser Focus', description: 'Develop laser-sharp focus that blocks out everything else', categoryId: 'focus', durationMinutes: 12, sortOrder: 1),
  TennisSession(id: 'fc02', title: 'Present Moment Tennis', description: 'Play one point at a time with total presence', categoryId: 'focus', durationMinutes: 10, sortOrder: 2),
  TennisSession(id: 'fc03', title: 'Focus Between Points', description: 'Use the time between points to reset and refocus', categoryId: 'focus', durationMinutes: 9, isPremium: true, sortOrder: 3),
  TennisSession(id: 'fc04', title: 'Distraction Immunity', description: 'Become immune to crowd noise, opponent tactics, and distractions', categoryId: 'focus', durationMinutes: 11, isPremium: true, sortOrder: 4),
  TennisSession(id: 'fc05', title: 'Single Point Focus', description: 'Give 100% attention to just this one point', categoryId: 'focus', durationMinutes: 7, isPremium: true, sortOrder: 5),
  TennisSession(id: 'fc06', title: 'Focus Under Pressure', description: 'Maintain crystal clear focus when the pressure is highest', categoryId: 'focus', durationMinutes: 13, isPremium: true, sortOrder: 6),
  TennisSession(id: 'fc07', title: 'Deep Focus State', description: 'Access a deep state of focused concentration', categoryId: 'focus', durationMinutes: 15, isPremium: true, sortOrder: 7),
  TennisSession(id: 'fc08', title: 'Focus Recovery', description: 'Quickly recover focus after a lapse or bad point', categoryId: 'focus', durationMinutes: 8, isPremium: true, sortOrder: 8),
  TennisSession(id: 'fc09', title: 'Match-Long Focus', description: 'Sustain high-quality focus for an entire match', categoryId: 'focus', durationMinutes: 14, isPremium: true, sortOrder: 9),
  TennisSession(id: 'fc10', title: 'Mental Spotlight', description: 'Direct your mental spotlight exactly where it needs to be', categoryId: 'focus', durationMinutes: 10, isPremium: true, sortOrder: 10),

  // ── FLOW STATE & RHYTHM (8 sessions) ──────────────────────────────────
  TennisSession(id: 'fl01', title: 'Enter the Zone', description: 'Learn to access the flow state where tennis feels effortless', categoryId: 'flow_state', durationMinutes: 14, sortOrder: 1),
  TennisSession(id: 'fl02', title: 'Natural Rhythm', description: 'Find your natural playing rhythm and tempo', categoryId: 'flow_state', durationMinutes: 10, sortOrder: 2),
  TennisSession(id: 'fl03', title: 'Effortless Excellence', description: 'Play at your highest level while feeling relaxed and easy', categoryId: 'flow_state', durationMinutes: 12, isPremium: true, sortOrder: 3),
  TennisSession(id: 'fl04', title: 'Flow Trigger', description: 'Activate your personal flow triggers to enter the zone faster', categoryId: 'flow_state', durationMinutes: 9, isPremium: true, sortOrder: 4),
  TennisSession(id: 'fl05', title: 'In the Groove', description: 'Get into a groove where every shot feels automatic', categoryId: 'flow_state', durationMinutes: 11, isPremium: true, sortOrder: 5),
  TennisSession(id: 'fl06', title: 'Tempo Control', description: 'Control the tempo of the match to suit your game', categoryId: 'flow_state', durationMinutes: 10, isPremium: true, sortOrder: 6),
  TennisSession(id: 'fl07', title: 'Free-Flowing Tennis', description: 'Let go of overthinking and play freely from instinct', categoryId: 'flow_state', durationMinutes: 13, isPremium: true, sortOrder: 7),
  TennisSession(id: 'fl08', title: 'Zone Maintenance', description: 'Stay in the zone once you find it — maintain peak performance', categoryId: 'flow_state', durationMinutes: 11, isPremium: true, sortOrder: 8),

  // ── TRUSTING YOUR INNER GAME (8 sessions) ─────────────────────────────
  TennisSession(id: 'ig01', title: 'Trust Your Instincts', description: 'Stop overthinking and trust your trained instincts', categoryId: 'inner_game', durationMinutes: 11, sortOrder: 1),
  TennisSession(id: 'ig02', title: 'Inner Game Confidence', description: 'Build deep inner confidence that goes beyond technique', categoryId: 'inner_game', durationMinutes: 13, sortOrder: 2),
  TennisSession(id: 'ig03', title: 'Instinctive Tennis', description: 'Play tennis from feel and instinct rather than conscious thought', categoryId: 'inner_game', durationMinutes: 10, isPremium: true, sortOrder: 3),
  TennisSession(id: 'ig04', title: 'Trust Your Training', description: 'Your body knows what to do — trust the hours of practice', categoryId: 'inner_game', durationMinutes: 9, isPremium: true, sortOrder: 4),
  TennisSession(id: 'ig05', title: 'Natural Expression', description: 'Let your tennis be a natural expression of who you are', categoryId: 'inner_game', durationMinutes: 12, isPremium: true, sortOrder: 5),
  TennisSession(id: 'ig06', title: 'Automatic Excellence', description: 'Let your best tennis happen automatically without forcing it', categoryId: 'inner_game', durationMinutes: 11, isPremium: true, sortOrder: 6),
  TennisSession(id: 'ig07', title: 'Inner Wisdom', description: 'Tap into the wisdom of your body and years of practice', categoryId: 'inner_game', durationMinutes: 14, isPremium: true, sortOrder: 7),
  TennisSession(id: 'ig08', title: 'Trust Under Pressure', description: 'Trust your game especially when the pressure is on', categoryId: 'inner_game', durationMinutes: 12, isPremium: true, sortOrder: 8),

  // ── CRITICAL MOMENTS (10 sessions) ────────────────────────────────────
  TennisSession(id: 'cm01', title: 'Tiebreak Warrior', description: 'Thrive in tiebreaks with composure and aggression', categoryId: 'critical_moments', durationMinutes: 12, sortOrder: 1),
  TennisSession(id: 'cm02', title: 'Recovery Between Games', description: 'Use changeovers to mentally reset and refuel', categoryId: 'critical_moments', durationMinutes: 7, sortOrder: 2),
  TennisSession(id: 'cm03', title: 'Match Point Master', description: 'Convert match points with calm, decisive execution', categoryId: 'critical_moments', durationMinutes: 10, isPremium: true, sortOrder: 3),
  TennisSession(id: 'cm04', title: 'Break Point Converter', description: 'Seize your chances on break points with ruthless focus', categoryId: 'critical_moments', durationMinutes: 11, isPremium: true, sortOrder: 4),
  TennisSession(id: 'cm05', title: 'Saving Break Points', description: 'Hold serve under pressure when facing break points', categoryId: 'critical_moments', durationMinutes: 12, isPremium: true, sortOrder: 5),
  TennisSession(id: 'cm06', title: 'First Set Domination', description: 'Set the tone by winning the first set with authority', categoryId: 'critical_moments', durationMinutes: 9, isPremium: true, sortOrder: 6),
  TennisSession(id: 'cm07', title: 'Third Set Thriller', description: 'Be at your best mentally in deciding sets', categoryId: 'critical_moments', durationMinutes: 13, isPremium: true, sortOrder: 7),
  TennisSession(id: 'cm08', title: 'The Great Comeback', description: 'Come back from any deficit with belief and determination', categoryId: 'critical_moments', durationMinutes: 14, isPremium: true, sortOrder: 8),
  TennisSession(id: 'cm09', title: 'Holding Serve Under Pressure', description: 'Hold your service games when the match is on the line', categoryId: 'critical_moments', durationMinutes: 11, isPremium: true, sortOrder: 9),
  TennisSession(id: 'cm10', title: 'Momentum Shifter', description: 'Turn the momentum of a match in your favor', categoryId: 'critical_moments', durationMinutes: 10, isPremium: true, sortOrder: 10),

  // ── WINNING SECTION (20 sessions) ─────────────────────────────────────
  // Pressure & Toughness (4)
  TennisSession(id: 'wn01', title: 'Clutch Points', description: 'Deliver your best tennis on the most important points', categoryId: 'winning', durationMinutes: 11, isPremium: true, sortOrder: 1),
  TennisSession(id: 'wn02', title: 'Comeback King', description: 'The mental blueprint for coming back from any situation', categoryId: 'winning', durationMinutes: 13, isPremium: true, sortOrder: 2),
  TennisSession(id: 'wn03', title: 'Pressure is Privilege', description: 'Reframe pressure as a privilege and thrive under it', categoryId: 'winning', durationMinutes: 10, isPremium: true, sortOrder: 3),
  TennisSession(id: 'wn04', title: 'Ice in Your Veins', description: 'Stay ice cold and clinical in the biggest moments', categoryId: 'winning', durationMinutes: 12, isPremium: true, sortOrder: 4),
  // Strategic Mindset (4)
  TennisSession(id: 'wn05', title: 'Reading Your Opponent', description: 'Develop the ability to read and anticipate opponent patterns', categoryId: 'winning', durationMinutes: 11, isPremium: true, sortOrder: 5),
  TennisSession(id: 'wn06', title: 'Chess Master', description: 'Think strategically — plan points like a chess grandmaster', categoryId: 'winning', durationMinutes: 14, isPremium: true, sortOrder: 6),
  TennisSession(id: 'wn07', title: 'Exploiting Weaknesses', description: 'Identify and systematically exploit opponent weaknesses', categoryId: 'winning', durationMinutes: 10, isPremium: true, sortOrder: 7),
  TennisSession(id: 'wn08', title: 'Momentum Control', description: 'Take control of match momentum and never let it go', categoryId: 'winning', durationMinutes: 12, isPremium: true, sortOrder: 8),
  // Mental Resilience (4)
  TennisSession(id: 'wn09', title: 'Bulletproof Confidence', description: 'Build confidence so strong that nothing can shake it', categoryId: 'winning', durationMinutes: 13, isPremium: true, sortOrder: 9),
  TennisSession(id: 'wn10', title: 'Bad Call Recovery', description: 'Immediately recover mentally from bad calls and unfair situations', categoryId: 'winning', durationMinutes: 8, isPremium: true, sortOrder: 10),
  TennisSession(id: 'wn11', title: 'Warrior Heart', description: 'Fight for every single point with a warrior spirit', categoryId: 'winning', durationMinutes: 11, isPremium: true, sortOrder: 11),
  TennisSession(id: 'wn12', title: 'Reset and Reload', description: 'Quickly reset after any point and reload for the next one', categoryId: 'winning', durationMinutes: 7, isPremium: true, sortOrder: 12),
  // Match Situations (4)
  TennisSession(id: 'wn13', title: 'First Set Domination', description: 'Establish early dominance and take the first set', categoryId: 'winning', durationMinutes: 10, isPremium: true, sortOrder: 13),
  TennisSession(id: 'wn14', title: 'Third Set Killer', description: 'Be the player who always wins the deciding set', categoryId: 'winning', durationMinutes: 12, isPremium: true, sortOrder: 14),
  TennisSession(id: 'wn15', title: 'Big Match Temperament', description: 'Perform at your peak in the most important matches', categoryId: 'winning', durationMinutes: 14, isPremium: true, sortOrder: 15),
  TennisSession(id: 'wn16', title: 'Doubles Synergy', description: 'Build unstoppable chemistry and communication with your partner', categoryId: 'winning', durationMinutes: 11, isPremium: true, sortOrder: 16),
  // Focus (4)
  TennisSession(id: 'wn17', title: 'Laser Focus Protocol', description: 'A step-by-step protocol for entering deep focus before matches', categoryId: 'winning', durationMinutes: 9, isPremium: true, sortOrder: 17),
  TennisSession(id: 'wn18', title: 'Zone State', description: 'Access and maintain the performance zone throughout a match', categoryId: 'winning', durationMinutes: 15, isPremium: true, sortOrder: 18),
  TennisSession(id: 'wn19', title: 'Distraction Shield', description: 'Build an impenetrable shield against all distractions', categoryId: 'winning', durationMinutes: 10, isPremium: true, sortOrder: 19),
  TennisSession(id: 'wn20', title: 'Point-by-Point Mastery', description: 'Master the art of playing one point at a time', categoryId: 'winning', durationMinutes: 12, isPremium: true, sortOrder: 20),
];
