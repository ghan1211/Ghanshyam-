import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { 
  CheckSquare, 
  Dumbbell, 
  Sword, 
  TrendingUp, 
  Settings as SettingsIcon, 
  Sparkles, 
  Plus, 
  X, 
  Upload, 
  RefreshCw, 
  Play, 
  Pause, 
  RotateCcw, 
  Trash2, 
  Check, 
  Award, 
  AlertCircle, 
  Clock, 
  BookOpen, 
  Scale, 
  ChevronRight, 
  Target, 
  Calendar,
  GraduationCap,
  History,
  FileText,
  Bookmark,
  PlusCircle,
  Tag,
  Palette,
  Bell,
  Volume2,
  Moon,
  Sun,
  Activity,
  ChevronLeft,
  PieChart,
  User,
  Zap,
  Info,
  BrainCircuit,
  Flame,
  FileDown
} from 'lucide-react';

const STORAGE_PREFIX = 'dayflow_web_pro_';

const db = {
  get: (collection, defaultVal = []) => {
    try {
      const item = localStorage.getItem(STORAGE_PREFIX + collection);
      return item ? JSON.parse(item) : defaultVal;
    } catch { return defaultVal; }
  },
  set: (collection, data) => {
    try {
      localStorage.setItem(STORAGE_PREFIX + collection, JSON.stringify(data));
    } catch (e) { console.error("Database Save Failure:", e); }
  }
};

// Seed baseline habits if missing
if (!localStorage.getItem(STORAGE_PREFIX + 'habits')) {
  db.set('habits', [
    { id: 'h1', title: 'Stance Hold (5 mins)', streak: 5, bestStreak: 12, completedDates: [] },
    { id: 'h2', title: 'Review Tactical Video', streak: 3, bestStreak: 8, completedDates: [] },
    { id: 'h3', title: 'Hydration (3L Daily)', streak: 7, bestStreak: 14, completedDates: [] }
  ]);
}

const COLOR_THEMES = {
  violet: { bg: 'bg-violet-500/10', border: 'border-violet-500/30', text: 'text-violet-400', badge: 'bg-violet-950/60', hex: '#8B5CF6' },
  coral: { bg: 'bg-rose-500/10', border: 'border-rose-500/30', text: 'text-rose-400', badge: 'bg-rose-950/60', hex: '#F43F5E' },
  mint: { bg: 'bg-emerald-500/10', border: 'border-emerald-500/30', text: 'text-emerald-400', badge: 'bg-emerald-950/60', hex: '#10B981' },
  gold: { bg: 'bg-amber-500/10', border: 'border-amber-500/30', text: 'text-amber-400', badge: 'bg-amber-950/60', hex: '#F59E0B' },
  indigo: { bg: 'bg-indigo-500/10', border: 'border-indigo-500/30', text: 'text-indigo-400', badge: 'bg-indigo-950/60', hex: '#6366F1' },
  cyan: { bg: 'bg-cyan-500/10', border: 'border-cyan-500/30', text: 'text-cyan-400', badge: 'bg-cyan-950/60', hex: '#06B6D4' }
};

const DEFAULT_SUBJECTS = {
  'Mathematics': COLOR_THEMES.violet,
  'Computer Science': COLOR_THEMES.indigo,
  'Physics': COLOR_THEMES.cyan,
  'Chemistry': COLOR_THEMES.mint,
  'Biology': COLOR_THEMES.mint,
  'Humanities': COLOR_THEMES.coral,
  'Other Subject': COLOR_THEMES.gold
};

const DEFAULT_FORMATS = ['Self-Study', 'Exam Prep', 'Lectures', 'Homework', 'Active Recall'];
const DEFAULT_FENCING_CATEGORIES = ['Footwork', 'Attack', 'Defense', 'Parry', 'Lunge', 'Drill', 'Match', 'Other'];
const DEFAULT_TODO_TAGS = ['Homework', 'Research', 'Athletics', 'Personal', 'General'];

const todayStr = () => new Date().toISOString().split('T')[0];

function playTone(freq = 440, duration = 0.15, type = 'sine', volume = 0.08) {
  try {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(freq, ctx.currentTime);
    gain.gain.setValueAtTime(volume, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + duration);
  } catch (e) {
    // Fail gracefully in non-supported browser configurations
  }
}

export default function App() {
  const [currentTab, setCurrentTab] = useState('today');
  const [toastMessage, setToastMessage] = useState(null);

  const triggerToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 3000);
  };

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }, [currentTab]);

  return (
    <div className="min-h-screen bg-[#0A0F1D] text-slate-100 flex flex-col font-sans selection:bg-violet-600/30 pb-20 relative overflow-x-hidden">
      {/* Background Ambient Blurs */}
      <div className="fixed top-0 left-1/4 w-[500px] h-[500px] bg-violet-600/5 rounded-full blur-[140px] pointer-events-none z-0" />
      <div className="fixed bottom-1/4 right-1/4 w-[400px] h-[400px] bg-rose-500/5 rounded-full blur-[120px] pointer-events-none z-0" />

      {/* Slide-In Toast Overlay Notification */}
      {toastMessage && (
        <div className="fixed top-4 left-1/2 -translate-x-1/2 z-50 bg-[#0E1626] border border-violet-500/40 px-5 py-3 rounded-2xl shadow-2xl flex items-center gap-2.5 animate-in slide-in-from-top duration-300">
          <Info className="w-4 h-4 text-violet-400" />
          <span className="text-xs font-semibold text-slate-200">{toastMessage}</span>
        </div>
      )}

      {/* Primary Workspace View Switcher */}
      <main className="flex-1 z-10 relative">
        {currentTab === 'today' && <Home triggerToast={triggerToast} />}
        {currentTab === 'workout' && <Workout triggerToast={triggerToast} />}
        {currentTab === 'fencing' && <Fencing triggerToast={triggerToast} />}
        {currentTab === 'progress' && <Progress triggerToast={triggerToast} />}
        {currentTab === 'settings' && <Settings triggerToast={triggerToast} />}
      </main>
      
      {/* Dynamic Bottom Navbar & Reminder Alarms */}
      <BottomNav currentTab={currentTab} setCurrentTab={setCurrentTab} />
      <ReminderManager triggerToast={triggerToast} />
    </div>
  );
}

function BottomNav({ currentTab, setCurrentTab }) {
  const items = [
    { id: 'today', label: 'Today', icon: CheckSquare, color: 'text-violet-500' },
    { id: 'workout', label: 'Workout', icon: Dumbbell, color: 'text-rose-500' },
    { id: 'fencing', label: 'Fencing', icon: Sword, color: 'text-amber-500' },
    { id: 'progress', label: 'Progress', icon: TrendingUp, color: 'text-emerald-500' },
    { id: 'settings', label: 'Settings', icon: SettingsIcon, color: 'text-slate-400' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-[#0E1626]/95 backdrop-blur-xl border-t border-slate-800/80 shadow-[0_-10px_25px_rgba(0,0,0,0.5)]">
      <div className="flex justify-around items-center h-16 max-w-lg mx-auto">
        {items.map(({ id, label, icon: Icon, color }) => {
          const isActive = currentTab === id;
          return (
            <button 
              key={id} 
              onClick={() => { playTone(580, 0.05, 'triangle'); setCurrentTab(id); }}
              className={`flex flex-col items-center gap-1 px-3 py-1.5 rounded-xl transition-all relative group ${
                isActive ? 'scale-110' : 'opacity-65 hover:opacity-90'
              }`}
            >
              <div className={`p-1.5 rounded-xl transition-all duration-300 ${isActive ? 'bg-slate-900 shadow-inner' : ''}`}>
                <Icon className={`w-5 h-5 transition-colors ${isActive ? color : 'text-slate-400'}`} />
              </div>
              <span className={`text-[9px] font-bold tracking-wider transition-colors uppercase ${isActive ? 'text-white' : 'text-slate-500'}`}>
                {label}
              </span>
              {isActive && (
                <span className="absolute bottom-0 w-1.5 h-1.5 bg-violet-600 rounded-full shadow shadow-violet-500" />
              )}
            </button>
          );
        })}
      </div>
    </nav>
  );
}

function ReminderManager({ triggerToast }) {
  const [modal, setModal] = useState(null);
  const [undoneTasks, setUndoneTasks] = useState([]);

  const getSettings = () => {
    try { 
      return db.get('settings_config', {
        morning: { enabled: true, time: '08:00' },
        evening: { enabled: true, time: '22:00' }
      }); 
    } catch { 
      return { morning: { enabled: true, time: '08:00' }, evening: { enabled: true, time: '22:00' } }; 
    }
  };

  const checkReminders = useCallback(async () => {
    const s = getSettings();
    const morning = s.morning || { enabled: true, time: '08:00' };
    const evening = s.evening || { enabled: true, time: '22:00' };
    const now = new Date();
    const timeStr = now.toTimeString().slice(0, 5);
    const today = todayStr();
    const skipMorning = timeStr >= evening.time;

    if (morning.enabled && !skipMorning && morning.time <= timeStr && s.lastMorning !== today) {
      s.lastMorning = today;
      db.set('settings_config', s);
      setModal('morning');
      playTone(660, 0.25, 'triangle', 0.1);
      return;
    }

    if (evening.enabled && evening.time <= timeStr && s.lastEvening !== today) {
      s.lastEvening = today;
      db.set('settings_config', s);

      const todos = db.get('todos', []).filter(t => t.date === today && !t.completed);
      const studies = db.get('studies', []).filter(s => s.date === today && !s.completed);
      const fencing = db.get('fencing_drills', []).filter(f => f.date === today && !f.completed);

      const undone = [
        ...todos.map(t => ({ title: t.title, type: 'todo' })),
        ...studies.map(s => ({ title: `${s.title} (${s.subject || 'Academic'})`, type: 'study' })),
        ...fencing.map(f => ({ title: f.title, type: 'fencing' })),
      ];

      if (undone.length > 0) {
        setUndoneTasks(undone);
        setModal('evening');
        playTone(554, 0.4, 'sawtooth', 0.1);
      }
      return;
    }

    if (s.lastBodyPrompt !== today) {
      const metrics = db.get('body_metrics', []);
      const latest = metrics[metrics.length - 1];
      const needsCheck = !latest || (now - new Date(latest.date)) / 86400000 >= 7;
      if (needsCheck) {
        s.lastBodyPrompt = today;
        db.set('settings_config', s);
        setModal('body');
        playTone(440, 0.2, 'sine', 0.08);
      }
    }
  }, []);

  useEffect(() => {
    const timer = setTimeout(checkReminders, 2500);
    const interval = setInterval(checkReminders, 15000); 
    return () => { clearTimeout(timer); clearInterval(interval); };
  }, [checkReminders]);

  return (
    <>
      {modal === 'morning' && <MorningModal onClose={() => setModal(null)} />}
      {modal === 'evening' && <EndOfDayModal tasks={undoneTasks} onClose={() => setModal(null)} triggerToast={triggerToast} />}
      {modal === 'body' && <BodyMetricModal onClose={() => setModal(null)} />}
    </>
  );
}

function MorningModal({ onClose }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/75 backdrop-blur-md p-4 animate-in fade-in duration-350">
      <div className="bg-[#0E1626] border border-slate-800 rounded-3xl p-6 max-w-sm w-full shadow-2xl space-y-4 text-center">
        <div className="w-14 h-14 rounded-full bg-violet-500/20 border border-violet-500/40 flex items-center justify-center mx-auto mb-2 animate-bounce">
          <Sun className="w-7 h-7 text-violet-400" />
        </div>
        <h2 className="text-xl font-black text-white uppercase tracking-tight">Rise &amp; Focus! 🌅</h2>
        <p className="text-slate-400 text-xs leading-relaxed">
          Start your morning by building today's academic checklist and training schedules. Setting priorities early guarantees seamless execution.
        </p>
        <button 
          onClick={() => { playTone(880, 0.1, 'sine'); onClose(); }} 
          className="w-full py-3 bg-violet-600 hover:bg-violet-700 text-white rounded-xl font-bold text-xs uppercase tracking-wider transition-all shadow-lg shadow-violet-600/25"
        >
          Plan My Workspace
        </button>
      </div>
    </div>
  );
}

function EndOfDayModal({ tasks, onClose, triggerToast }) {
  const [reasons, setReasons] = useState({});
  const [saving, setSaving] = useState(false);
  const today = todayStr();

  const handleSave = () => {
    setSaving(true);
    const updates = tasks.map(t => ({
      task_title: t.title,
      task_type: t.type,
      reason: reasons[t.title]?.trim() || 'Deferred for future alignment',
      date: today
    }));
    const list = db.get('task_reviews', []);
    db.set('task_reviews', [...list, ...updates]);
    setSaving(false);
    triggerToast("Reflection notes compiled safely.");
    playTone(1046, 0.3, 'sine');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-in fade-in duration-200">
      <div className="bg-[#0E1626] border border-slate-800 rounded-3xl p-6 max-w-md w-full shadow-2xl max-h-[85vh] overflow-y-auto space-y-4">
        <div className="w-14 h-14 rounded-full bg-rose-500/20 border border-rose-500/40 flex items-center justify-center mx-auto mb-2">
          <Moon className="w-7 h-7 text-rose-400" />
        </div>
        <h2 className="text-xl font-black text-center text-white uppercase tracking-tight">System Audit 🌙</h2>
        <p className="text-slate-400 text-center text-xs leading-relaxed">
          You have {tasks.length} task{tasks.length > 1 ? 's' : ''} left incomplete today. Log your reflection reasons to optimize tomorrow's workload:
        </p>
        
        <div className="space-y-3 max-h-56 overflow-y-auto pr-1">
          {tasks.map((task, i) => (
            <div key={i} className="p-3 bg-slate-950/60 rounded-2xl border border-slate-900 space-y-2">
              <div className="flex items-center gap-2">
                <span className={`w-2 h-2 rounded-full ${task.type === 'study' ? 'bg-violet-500' : task.type === 'workout' ? 'bg-rose-500' : 'bg-amber-500'}`} />
                <span className="text-xs font-bold text-slate-300 truncate">{task.title}</span>
              </div>
              <input
                type="text"
                placeholder="E.g., run out of time, physical fatigue, extra rest..."
                value={reasons[task.title] || ''}
                onChange={e => setReasons({ ...reasons, [task.title]: e.target.value })}
                className="w-full px-3 py-2 text-xs bg-[#0A0F1D] rounded-xl border border-slate-800 text-slate-200 focus:outline-none focus:border-rose-500"
              />
            </div>
          ))}
        </div>

        <button 
          onClick={handleSave} 
          disabled={saving}
          className="w-full py-3 bg-rose-500 hover:bg-rose-600 text-white rounded-xl font-bold text-xs uppercase tracking-wider transition-all disabled:opacity-50 shadow-lg shadow-rose-500/20"
        >
          {saving ? 'Writing Logs...' : 'Commit Reflection Logs'}
        </button>
      </div>
    </div>
  );
}

function BodyMetricModal({ onClose }) {
  const [weight, setWeight] = useState('');
  const [height, setHeight] = useState('');
  const [saving, setSaving] = useState(false);
  const today = todayStr();

  const handleSave = () => {
    if (!weight) return;
    setSaving(true);
    const list = db.get('body_metrics', []);
    db.set('body_metrics', [...list, {
      weight_kg: parseFloat(weight),
      height_cm: height ? parseFloat(height) : null,
      date: today,
    }]);
    setSaving(false);
    playTone(1320, 0.2, 'sine');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-md p-4 animate-in zoom-in-95 duration-200">
      <div className="bg-[#0E1626] border border-slate-800 rounded-3xl p-6 max-w-sm w-full shadow-2xl space-y-4">
        <div className="w-14 h-14 rounded-full bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center mx-auto mb-2">
          <Scale className="w-7 h-7 text-emerald-400" />
        </div>
        <h2 className="text-xl font-black text-center text-white uppercase tracking-tight">Weekly Check-in ⚖️</h2>
        <p className="text-slate-400 text-center text-xs">Keep your athletic biometric telemetry current. Log today's weight and height:</p>
        
        <div className="space-y-3">
          <div>
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1 block">Weight (kg)</label>
            <input 
              type="number" 
              step="0.1" 
              value={weight} 
              onChange={e => setWeight(e.target.value)}
              className="w-full px-3 py-2.5 bg-slate-950 border border-slate-850 rounded-xl focus:outline-none focus:border-emerald-500 text-slate-100" 
              placeholder="e.g. 74.5" 
            />
          </div>
          <div>
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1 block">Height (cm)</label>
            <input 
              type="number" 
              step="0.1" 
              value={height} 
              onChange={e => setHeight(e.target.value)}
              className="w-full px-3 py-2.5 bg-slate-950 border border-slate-850 rounded-xl focus:outline-none focus:border-emerald-500 text-slate-100" 
              placeholder="e.g. 182.0" 
            />
          </div>
        </div>

        <div className="flex gap-2">
          <button onClick={onClose} className="flex-1 py-2.5 bg-slate-900 border border-slate-800 text-slate-400 rounded-xl text-xs font-bold transition-all hover:bg-slate-850">Skip</button>
          <button 
            onClick={handleSave} 
            disabled={saving || !weight}
            className="flex-1 py-2.5 bg-emerald-500 text-slate-950 rounded-xl text-xs font-black uppercase tracking-wider transition-all hover:opacity-90 disabled:opacity-40 shadow-lg shadow-emerald-500/20"
          >
            {saving ? 'Saving...' : 'Save Metrics'}
          </button>
        </div>
      </div>
    </div>
  );
}

function Home({ triggerToast }) {
  const [studies, setStudies] = useState([]);
  const [todos, setTodos] = useState([]);
  const [workout, setWorkout] = useState(null);
  const [loading, setLoading] = useState(true);
  const [dateStr, setDateStr] = useState('');
  const today = todayStr();

  const loadDashboardData = useCallback(() => {
    setLoading(true);
    const s = db.get('studies', []).filter(item => item.date === today);
    const t = db.get('todos', []).filter(item => item.date === today);
    const w = db.get('workout_days', []);
    
    let dayIdx = new Date().getDay();
    if (dayIdx === 0) dayIdx = 7; 
    
    setStudies(s);
    setTodos(t);
    setWorkout(w.find(d => d.day_index === dayIdx) || null);
    setLoading(false);
  }, [today]);

  useEffect(() => {
    loadDashboardData();
    setDateStr(new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' }));
  }, [loadDashboardData]);

  const allTasks = [
    ...studies.map(s => ({ completed: s.completed })),
    ...todos.map(t => ({ completed: t.completed })),
    ...(workout?.exercises || []).map(e => ({ completed: e.completed }))
  ];
  const doneCount = allTasks.filter(t => t.completed).length;
  const progressPercent = allTasks.length > 0 ? Math.round((doneCount / allTasks.length) * 100) : 0;

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center p-12 text-slate-500 space-y-3">
        <RefreshCw className="w-8 h-8 animate-spin text-violet-500" />
        <span className="text-xs font-bold uppercase tracking-widest">Loading Workspace...</span>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto px-4 pt-6 space-y-6 pb-12 animate-in fade-in duration-300">
      
      {/* Dashboard Progress Ring Header */}
      <div className="flex items-center justify-between bg-[#0E1626]/60 border border-slate-900 rounded-3xl p-4 backdrop-blur-md shadow-xl">
        <div>
          <span className="text-[10px] font-extrabold text-violet-500 tracking-widest uppercase block mb-0.5">ACADEMIC ATHLETE DECK</span>
          <h1 className="text-2xl font-black text-white tracking-tight flex items-center gap-1">TODAY</h1>
          <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">{dateStr}</p>
        </div>

        <div className="relative w-16 h-16 flex items-center justify-center">
          <svg className="w-16 h-16 transform -rotate-90">
            <circle cx="32" cy="32" r="26" className="stroke-slate-900 fill-none" strokeWidth="5" />
            <circle cx="32" cy="32" r="26" className="stroke-violet-500 fill-none transition-all duration-500" strokeWidth="5"
              strokeDasharray={2 * Math.PI * 26}
              strokeDashoffset={2 * Math.PI * 26 * (1 - progressPercent / 100)}
              strokeLinecap="round" />
          </svg>
          <span className="absolute text-xs font-black text-white">{progressPercent}%</span>
        </div>
      </div>

      {/* Linked Academic Study block workspace */}
      <StudySection studies={studies} today={today} onChanged={loadDashboardData} triggerToast={triggerToast} />

      {/* Active Workout split tracker card */}
      <WorkoutSummary workout={workout} />

      {/* Checklist Tasks panel */}
      <TodoSection todos={todos} today={today} onChanged={loadDashboardData} triggerToast={triggerToast} />

    </div>
  );
}

function StudySection({ studies, today, onChanged, triggerToast }) {
  const [adding, setAdding] = useState(false);
  const [title, setTitle] = useState('');
  const [subject, setSubject] = useState('Mathematics');
  const [startTime, setStartTime] = useState('09:00');
  const [endTime, setEndTime] = useState('10:00');
  const [format, setFormat] = useState('Self-Study');

  const [customSubjects, setCustomSubjects] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('custom_subjects')) || [];
    } catch {
      return [];
    }
  });
  const [customFormats, setCustomFormats] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('custom_formats')) || [];
    } catch {
      return [];
    }
  });
  const [showSubjectCreator, setShowSubjectCreator] = useState(false);
  const [newSubjectName, setNewSubjectName] = useState('');
  const [newSubjectColor, setNewSubjectColor] = useState('violet');
  const [showFormatCreator, setShowFormatCreator] = useState(false);
  const [newFormatName, setNewFormatName] = useState('');

  // Pomodoro timer configurations
  const [activeBlock, setActiveBlock] = useState(null);
  const [timePreset, setTimePreset] = useState(1500); 
  const [timeLeft, setTimeLeft] = useState(1500);
  const [timerRunning, setTimerRunning] = useState(false);
  const [sprintsCompleted, setSprintsCompleted] = useState(0);
  const timerRef = useRef(null);

  const getSubjectStyle = (subName) => {
    if (DEFAULT_SUBJECTS[subName]) return DEFAULT_SUBJECTS[subName];
    const match = customSubjects.find(s => s.name === subName);
    if (match && COLOR_THEMES[match.color]) return COLOR_THEMES[match.color];
    return DEFAULT_SUBJECTS['Other Subject'];
  };

  useEffect(() => {
    if (timerRunning) {
      timerRef.current = setInterval(() => {
        setTimeLeft(prev => {
          if (prev <= 1) {
            handleTimerFinish();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } else {
      clearInterval(timerRef.current);
    }
    return () => clearInterval(timerRef.current);
  }, [timerRunning]);

  const handleTimerFinish = () => {
    setTimerRunning(false);
    setSprintsCompleted(prev => prev + 1);
    triggerToast("Sprint finished! Focus session complete.");
    playTone(880, 0.4, 'sine', 0.1);
    setTimeout(() => playTone(1200, 0.35, 'sine', 0.1), 150);
  };

  const handleCreateSubject = () => {
    const trimmed = newSubjectName.trim();
    if (!trimmed) return;
    const exists = Object.keys(DEFAULT_SUBJECTS).includes(trimmed) || customSubjects.some(s => s.name.toLowerCase() === trimmed.toLowerCase());
    if (exists) {
      triggerToast("Subject classification already exists.");
      return;
    }

    const list = [...customSubjects, { name: trimmed, color: newSubjectColor }];
    localStorage.setItem('custom_subjects', JSON.stringify(list));
    setCustomSubjects(list);
    setSubject(trimmed);
    setNewSubjectName('');
    setShowSubjectCreator(false);
    playTone(1050, 0.1, 'sine');
  };

  const handleCreateFormat = () => {
    const trimmed = newFormatName.trim();
    if (!trimmed) return;
    const exists = DEFAULT_FORMATS.includes(trimmed) || customFormats.includes(trimmed);
    if (exists) {
      triggerToast("Format classification already exists.");
      return;
    }

    const list = [...customFormats, trimmed];
    localStorage.setItem('custom_formats', JSON.stringify(list));
    setCustomFormats(list);
    setFormat(trimmed);
    setNewFormatName('');
    setShowFormatCreator(false);
    playTone(1050, 0.1, 'triangle');
  };

  const toggle = (s) => {
    const all = db.get('studies', []);
    const updated = all.map(item => item.id === s.id ? { ...item, completed: !item.completed } : item);
    db.set('studies', updated);
    playTone(950, 0.08, 'sine');
    onChanged();
  };

  const remove = (id) => {
    const all = db.get('studies', []);
    const updated = all.filter(item => item.id !== id);
    db.set('studies', updated);
    playTone(210, 0.15, 'sawtooth');
    if (activeBlock?.id === id) {
      setActiveBlock(null);
      setTimerRunning(false);
    }
    onChanged();
  };

  const add = () => {
    if (!title.trim()) return;
    const all = db.get('studies', []);
    all.push({
      id: 'study_' + Date.now() + Math.random(),
      title: title.trim(), 
      subject, 
      start_time: startTime, 
      end_time: endTime, 
      study_type: format,
      completed: false,
      date: today 
    });
    db.set('studies', all);
    setTitle(''); 
    setAdding(false); 
    playTone(1100, 0.1, 'sine');
    onChanged();
  };

  const triggerLinkPomo = (block) => {
    setActiveBlock(block);
    setTimeLeft(1500);
    setTimePreset(1500);
    setTimerRunning(false);
    playTone(740, 0.1, 'sine');
  };

  return (
    <div className="bg-[#0E1626] rounded-3xl p-5 border border-slate-850 shadow-xl space-y-4">
      
      <div className="flex items-center justify-between border-b border-slate-800/80 pb-2">
        <div className="flex items-center gap-2">
          <BookOpen className="w-5 h-5 text-violet-500" />
          <h2 className="font-extrabold text-sm uppercase tracking-wider">Academic Study Plan</h2>
        </div>
        <button 
          onClick={() => setAdding(!adding)} 
          className="text-violet-400 bg-slate-950 p-1.5 rounded-xl border border-slate-850 hover:bg-slate-900 transition-all animate-pulse"
        >
          <Plus className="w-4 h-4" />
        </button>
      </div>

      {adding && (
        <div className="bg-slate-950 p-4 rounded-2xl border border-slate-850 space-y-3">
          <div className="space-y-1">
            <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Study Task Focus</label>
            <input 
              value={title} 
              onChange={e => setTitle(e.target.value)} 
              placeholder="E.g., Proof integration formulas, review Mitosis..."
              className="w-full px-3 py-2 text-xs bg-[#0E1626] rounded-xl border border-slate-800 text-slate-200 focus:outline-none focus:border-violet-500" 
            />
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <div className="flex justify-between items-center">
                <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Subject</label>
                <button onClick={() => setShowSubjectCreator(!showSubjectCreator)} className="text-[8px] text-violet-400 font-bold">+ Custom</button>
              </div>
              
              {showSubjectCreator ? (
                <div className="p-2 bg-[#0E1626] border border-slate-800 rounded-lg space-y-2">
                  <input 
                    placeholder="Subject Name" 
                    value={newSubjectName} 
                    onChange={e => setNewSubjectName(e.target.value)}
                    className="w-full text-[9px] bg-slate-950 border border-slate-800 text-slate-200 p-1 rounded focus:outline-none" 
                  />
                  <div className="flex justify-between items-center gap-1">
                    <select 
                      value={newSubjectColor} 
                      onChange={e => setNewSubjectColor(e.target.value)}
                      className="text-[9px] bg-slate-950 text-slate-400 p-1 rounded focus:outline-none"
                    >
                      {Object.keys(COLOR_THEMES).map(c => <option key={c} value={c}>{c}</option>)}
                    </select>
                    <button onClick={handleCreateSubject} className="text-[9px] bg-violet-600 px-2 py-1 rounded text-white font-bold">Add</button>
                  </div>
                </div>
              ) : (
                <select 
                  value={subject} 
                  onChange={e => setSubject(e.target.value)}
                  className="w-full text-xs bg-[#0E1626] rounded-xl border border-slate-800 p-2.5 text-slate-200 focus:outline-none"
                >
                  {Object.keys(DEFAULT_SUBJECTS).map(s => <option key={s} value={s}>{s}</option>)}
                  {customSubjects.map(s => <option key={s.name} value={s.name}>{s.name}</option>)}
                </select>
              )}
            </div>

            <div className="space-y-1">
              <div className="flex justify-between items-center">
                <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Study Format</label>
                <button onClick={() => setShowFormatCreator(!showFormatCreator)} className="text-[8px] text-violet-400 font-bold">+ Custom</button>
              </div>

              {showFormatCreator ? (
                <div className="p-2 bg-[#0E1626] border border-slate-800 rounded-lg space-y-2">
                  <input 
                    placeholder="Format Name" 
                    value={newFormatName} 
                    onChange={e => setNewFormatName(e.target.value)}
                    className="w-full text-[9px] bg-slate-950 border border-slate-800 text-slate-200 p-1 rounded focus:outline-none" 
                  />
                  <button onClick={handleCreateFormat} className="w-full text-[9px] bg-violet-600 py-1 rounded text-white font-bold">Add Format</button>
                </div>
              ) : (
                <select 
                  value={format} 
                  onChange={e => setFormat(e.target.value)}
                  className="w-full text-xs bg-[#0E1626] rounded-xl border border-slate-800 p-2.5 text-slate-200 focus:outline-none"
                >
                  {DEFAULT_FORMATS.map(f => <option key={f} value={f}>{f}</option>)}
                  {customFormats.map(f => <option key={f} value={f}>{f}</option>)}
                </select>
              )}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Start Time</label>
              <input 
                type="time" 
                value={startTime} 
                onChange={e => setStartTime(e.target.value)}
                className="w-full text-xs bg-[#0E1626] rounded-xl border border-slate-800 p-2.5 text-slate-200 focus:outline-none" 
              />
            </div>
            <div className="space-y-1">
              <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">End Time</label>
              <input 
                type="time" 
                value={endTime} 
                onChange={e => setEndTime(e.target.value)}
                className="w-full text-xs bg-[#0E1626] rounded-xl border border-slate-800 p-2.5 text-slate-200 focus:outline-none" 
              />
            </div>
          </div>

          <button 
            onClick={add} 
            className="w-full py-2 bg-violet-600 hover:bg-violet-700 text-white rounded-xl text-xs font-bold uppercase transition-all shadow-lg shadow-violet-600/20"
          >
            Schedule Academic Block
          </button>
        </div>
      )}

      {activeBlock && (
        <div className="p-4 bg-slate-950 border border-violet-500/30 rounded-2xl space-y-3 relative overflow-hidden animate-in slide-in-from-top duration-250">
          <div className="flex justify-between items-center">
            <div>
              <span className="text-[8px] bg-violet-500/15 text-violet-400 border border-violet-500/30 px-1.5 py-0.5 rounded uppercase font-bold">
                Linked Workstation
              </span>
              <p className="text-xs font-bold text-white mt-1 truncate max-w-[180px]">{activeBlock.title}</p>
            </div>
            <span className="text-[10px] font-bold text-slate-400 font-mono">Completed Sprints: {sprintsCompleted}</span>
          </div>

          <div className="flex items-center justify-between bg-[#0E1626] p-3 rounded-xl border border-slate-850">
            <div>
              <span className="text-[8px] text-slate-500 uppercase font-extrabold tracking-wider">Time Left</span>
              <div className="text-2xl font-black font-mono text-white">
                {Math.floor(timeLeft / 60)}:{(timeLeft % 60).toString().padStart(2, '0')}
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <button 
                onClick={() => setTimerRunning(!timerRunning)} 
                className="p-2 bg-violet-600 hover:bg-violet-700 rounded-lg text-white"
              >
                {timerRunning ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
              </button>
              <button 
                onClick={() => { setTimeLeft(timePreset); setTimerRunning(false); }} 
                className="p-2 bg-slate-900 border border-slate-800 text-slate-400 rounded-lg hover:text-white"
              >
                <RotateCcw className="w-4 h-4" />
              </button>
              <button onClick={() => setActiveBlock(null)} className="p-2 text-slate-500 hover:text-rose-500">
                <X className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Scheduled study blocks list */}
      <div className="space-y-2">
        {studies.length === 0 && (
          <p className="text-xs text-slate-500 italic py-4 text-center bg-slate-950/60 rounded-2xl border border-slate-900/60">
            No study blocks scheduled today. Click "+" above to configure.
          </p>
        )}
        {studies.map(s => {
          const style = getSubjectStyle(s.subject);
          return (
            <div 
              key={s.id} 
              className={`p-3 bg-slate-950/60 hover:bg-slate-950 rounded-2xl border flex items-center justify-between transition-all ${
                s.completed ? 'border-emerald-500/20 opacity-60' : 'border-slate-850/85'
              }`}
            >
              <div className="flex items-center gap-3 flex-1 min-w-0">
                <button 
                  onClick={() => toggle(s)} 
                  className={`w-5 h-5 rounded-md border flex items-center justify-center flex-shrink-0 transition-all ${
                    s.completed ? 'bg-emerald-500 border-emerald-500 text-slate-950' : 'border-slate-700'
                  }`}
                >
                  {s.completed && <Check className="w-3.5 h-3.5 stroke-[4]" />}
                </button>

                <div className="flex-1 min-w-0">
                  <p className={`text-xs font-bold text-white truncate ${s.completed ? 'line-through text-slate-500' : ''}`}>{s.title}</p>
                  <div className="flex flex-wrap items-center gap-1 mt-1">
                    <span className={`text-[8px] font-black px-1.5 py-0.5 rounded uppercase tracking-wider border ${style.bg} ${style.text} ${style.border}`}>
                      {s.subject || 'Other'}
                    </span>
                    {s.start_time && (
                      <span className="text-[8px] text-slate-400 bg-slate-900 border border-slate-800 px-1 py-0.5 rounded font-mono">
                        🕒 {s.start_time} - {s.end_time}
                      </span>
                    )}
                    {s.study_type && (
                      <span className="text-[8px] text-violet-400 bg-violet-500/10 px-1 py-0.5 rounded border border-violet-500/20 uppercase font-extrabold font-mono">
                        {s.study_type}
                      </span>
                    )}
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-1.5 ml-2">
                <button 
                  onClick={() => triggerLinkPomo(s)} 
                  className="p-1.5 bg-violet-500/10 text-violet-400 border border-violet-500/25 rounded-lg hover:bg-violet-500/20"
                  title="Link Pomodoro Focus Loop"
                >
                  <Clock className="w-3.5 h-3.5" />
                </button>
                <button onClick={() => remove(s.id)} className="p-1.5 text-slate-600 hover:text-rose-500">
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          );
        })}
      </div>

    </div>
  );
}

function WorkoutSummary({ workout }) {
  if (!workout) {
    return (
      <div className="bg-[#0E1626] rounded-3xl p-5 border border-slate-850 shadow-xl space-y-1 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-32 h-32 bg-rose-500/5 rounded-full blur-[30px] pointer-events-none" />
        <div className="flex items-center gap-2 mb-1">
          <Dumbbell className="w-5 h-5 text-rose-500" />
          <h2 className="font-extrabold text-sm uppercase tracking-wider">Today's Split</h2>
        </div>
        <p className="text-xs text-slate-400">Rest day! Enjoy physical recover cycles and active tissue repair. 🌿</p>
      </div>
    );
  }

  const exercises = workout.exercises || [];
  const completed = exercises.filter(e => e.completed).length;
  const percent = exercises.length > 0 ? Math.round((completed / exercises.length) * 100) : 0;

  return (
    <div className="bg-[#0E1626] rounded-3xl p-5 border border-slate-850 shadow-xl relative overflow-hidden transition-all">
      <div className="absolute top-0 right-0 w-32 h-32 bg-rose-500/5 rounded-full blur-[30px] pointer-events-none" />
      
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <Dumbbell className="w-5 h-5 text-rose-500" />
          <h2 className="font-extrabold text-sm uppercase tracking-wider">Today's Split</h2>
        </div>
      </div>

      <div className="flex items-center justify-between">
        <div>
          <p className="font-black text-lg text-white">{workout.label}</p>
          <p className="text-xs text-slate-400 mt-1">{completed} of {exercises.length} exercises logged today</p>
        </div>

        <div className="w-12 h-12 rounded-full bg-rose-500/15 border border-rose-500/30 flex items-center justify-center">
          <span className="text-xs font-black text-rose-400">{percent}%</span>
        </div>
      </div>
    </div>
  );
}

function TodoSection({ todos, today, onChanged, triggerToast }) {
  const [title, setTitle] = useState('');
  const [priority, setPriority] = useState('medium');
  const [tag, setTag] = useState('General');

  const [customTags, setCustomTags] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('custom_tags')) || [];
    } catch {
      return [];
    }
  });
  const [showTagCreator, setShowTagCreator] = useState(false);
  const [newTagName, setNewTagName] = useState('');

  const handleCreateTag = () => {
    const trimmed = newTagName.trim();
    if (!trimmed) return;
    const exists = DEFAULT_TODO_TAGS.includes(trimmed) || customTags.includes(trimmed);
    if (exists) {
      triggerToast("Tag classification already exists.");
      return;
    }

    const list = [...customTags, trimmed];
    localStorage.setItem('custom_tags', JSON.stringify(list));
    setCustomTags(list);
    setTag(trimmed);
    setNewTagName('');
    setShowTagCreator(false);
    playTone(1050, 0.08, 'sine');
  };

  const toggle = (t) => {
    const all = db.get('todos', []);
    const updated = all.map(item => item.id === t.id ? { ...item, completed: !item.completed } : item);
    db.set('todos', updated);
    playTone(1050, 0.08, 'sine');
    onChanged();
  };

  const remove = (id) => {
    const all = db.get('todos', []);
    const updated = all.filter(item => item.id !== id);
    db.set('todos', updated);
    playTone(180, 0.15, 'sawtooth');
    onChanged();
  };

  const add = () => {
    if (!title.trim()) return;
    const all = db.get('todos', []);
    all.push({
      id: 'todo_' + Date.now() + Math.random(),
      title: title.trim(), 
      priority, 
      tag, 
      completed: false,
      date: today 
    });
    db.set('todos', all);
    setTitle('');
    playTone(1150, 0.1, 'sine');
    onChanged();
  };

  return (
    <div className="bg-[#0E1626] rounded-3xl p-5 border border-slate-850 shadow-xl space-y-4">
      <div className="flex items-center gap-2 border-b border-slate-800/80 pb-2">
        <CheckSquare className="w-5 h-5 text-emerald-400" />
        <h2 className="font-extrabold text-sm uppercase tracking-wider">To-Do Checklist</h2>
      </div>

      <div className="bg-slate-950 p-4 rounded-2xl border border-slate-850 space-y-3">
        <div className="space-y-1">
          <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">New Objective</label>
          <input 
            value={title} 
            onChange={e => setTitle(e.target.value)} 
            placeholder="Add task to day flow..."
            className="w-full px-3 py-2 text-xs bg-[#0E1626] rounded-xl border border-slate-850 text-slate-200 focus:outline-none focus:border-emerald-500" 
          />
        </div>

        <div className="grid grid-cols-2 gap-2">
          <div className="space-y-1">
            <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Priority</label>
            <select 
              value={priority} 
              onChange={e => setPriority(e.target.value)}
              className="w-full text-xs bg-[#0E1626] rounded-xl border border-slate-850 p-2 text-slate-200 focus:outline-none"
            >
              <option value="high">🔥 High</option>
              <option value="medium">⚡ Medium</option>
              <option value="low">🌱 Low</option>
            </select>
          </div>

          <div className="space-y-1">
            <div className="flex justify-between items-center">
              <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Tag</label>
              <button onClick={() => setShowTagCreator(!showTagCreator)} className="text-[8px] text-emerald-400 font-bold">+ New</button>
            </div>

            {showTagCreator ? (
              <div className="p-2 bg-[#0E1626] border border-slate-850 rounded-lg space-y-2">
                <input 
                  placeholder="Tag Title" 
                  value={newTagName} 
                  onChange={e => setNewTagName(e.target.value)}
                  className="w-full text-[9px] bg-slate-950 border border-slate-850 text-slate-200 p-1 rounded focus:outline-none" 
                />
                <button onClick={handleCreateTag} className="w-full text-[9px] bg-emerald-500 py-1 rounded text-slate-950 font-bold">Add</button>
              </div>
            ) : (
              <select 
                value={tag} 
                onChange={e => setTag(e.target.value)}
                className="w-full text-xs bg-[#0E1626] rounded-xl border border-slate-850 p-2 text-slate-200 focus:outline-none"
              >
                {DEFAULT_TODO_TAGS.map(t => <option key={t} value={t}>{t}</option>)}
                {customTags.map(t => <option key={t} value={t}>{t}</option>)}
              </select>
            )}
          </div>
        </div>

        <button 
          onClick={add} 
          className="w-full py-2 bg-emerald-500 hover:bg-emerald-600 text-slate-950 rounded-xl text-xs font-black uppercase tracking-wider transition-all shadow-lg shadow-emerald-500/20"
        >
          Inject Objective
        </button>
      </div>

      <div className="space-y-2">
        {todos.length === 0 && (
          <p className="text-xs text-slate-500 italic py-4 text-center bg-slate-950/60 rounded-2xl border border-slate-900/60">
            Checklist is pristine. Keep it up!
          </p>
        )}
        {todos.map(t => (
          <div 
            key={t.id} 
            className={`p-3 bg-slate-950/60 rounded-2xl border border-slate-850 flex items-center justify-between transition-all ${
              t.completed ? 'border-emerald-500/10 opacity-60' : ''
            }`}
          >
            <div className="flex items-center gap-3 flex-1 min-w-0">
              <button onClick={() => toggle(t)} className="flex-shrink-0">
                <span className={`w-5 h-5 rounded-md border-2 flex items-center justify-center transition-all ${
                  t.completed ? 'bg-emerald-500 border-emerald-500 text-slate-950' : 'border-slate-700 hover:border-slate-500'
                }`}>
                  {t.completed && <Check className="w-3.5 h-3.5 stroke-[4]" />}
                </span>
              </button>

              <div className="flex-1 min-w-0">
                <p className={`text-xs font-bold text-white truncate ${t.completed ? 'line-through text-slate-500' : ''}`}>{t.title}</p>
                <div className="flex items-center gap-1.5 mt-1">
                  <span className={`text-[8px] font-black uppercase tracking-wider px-1.5 py-0.5 rounded border ${
                    t.priority === 'high' 
                      ? 'bg-rose-500/10 text-rose-400 border-rose-500/20' 
                      : t.priority === 'medium'
                        ? 'bg-amber-500/10 text-amber-400 border-amber-500/20'
                        : 'bg-slate-900 text-slate-400 border-slate-800'
                  }`}>
                    {t.priority}
                  </span>
                  <span className="text-[8px] bg-emerald-500/10 text-emerald-400 px-1.5 py-0.5 rounded border border-emerald-500/20 font-extrabold uppercase font-mono">
                    {t.tag || 'General'}
                  </span>
                </div>
              </div>
            </div>

            <button onClick={() => remove(t.id)} className="p-1.5 text-slate-600 hover:text-rose-500 transition-colors ml-2">
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>

    </div>
  );
}

function Workout({ triggerToast }) {
  const [days, setDays] = useState([]);
  const [selectedIdx, setSelectedIdx] = useState(1);
  const [loading, setLoading] = useState(true);

  // Custom split builders
  const [showBuilder, setShowBuilder] = useState(false);
  const [builderDay, setBuilderDay] = useState(1);
  const [builderLabel, setBuilderLabel] = useState('Push Workout');
  const [builderDesc, setBuilderDesc] = useState('Hypertrophy focus');
  const [builderExercises, setBuilderExercises] = useState([]);

  // Draft exercise adding
  const [exName, setExName] = useState('');
  const [exSets, setExSets] = useState(3);
  const [exReps, setExReps] = useState('10-12');

  const loadWorkoutData = useCallback(() => {
    setLoading(true);
    const data = db.get('workout_days', []);
    setDays(data);
    setLoading(false);
  }, []);

  useEffect(() => {
    loadWorkoutData();
  }, [loadWorkoutData]);

  const addExerciseToDraft = () => {
    if (!exName.trim()) return;
    setBuilderExercises([...builderExercises, { 
      name: exName.trim(), 
      sets: parseInt(exSets) || 3, 
      reps: exReps.trim() || '10', 
      completed: false 
    }]);
    setExName('');
  };

  const handleCreateCustomSplit = () => {
    if (!builderLabel.trim()) return;

    const list = db.get('workout_days', []);
    const updated = list.filter(d => d.day_index !== builderDay);

    updated.push({
      id: 'workout_' + Date.now() + Math.random(),
      label: builderLabel.trim(),
      day_index: builderDay,
      description: builderDesc.trim(),
      exercises: builderExercises
    });

    db.set('workout_days', updated);
    setBuilderLabel('');
    setBuilderDesc('');
    setBuilderExercises([]);
    setShowBuilder(false);
    playTone(1100, 0.2, 'triangle');
    loadWorkoutData();
  };

  const toggleExerciseStatus = (splitId, exIdx) => {
    const list = db.get('workout_days', []);
    const updated = list.map(d => {
      if (d.id === splitId) {
        const exercises = [...(d.exercises || [])];
        exercises[exIdx] = { ...exercises[exIdx], completed: !exercises[exIdx].completed };
        return { ...d, exercises };
      }
      return d;
    });
    db.set('workout_days', updated);
    playTone(1050, 0.08, 'sine');
    loadWorkoutData();
  };

  const deleteSplitPlan = (id) => {
    const list = db.get('workout_days', []);
    const updated = list.filter(d => d.id !== id);
    db.set('workout_days', updated);
    playTone(180, 0.15, 'sawtooth');
    loadWorkoutData();
  };

  const selectedDayPlan = days.find(d => d.day_index === selectedIdx);

  return (
    <div className="max-w-md mx-auto px-4 pt-6 space-y-6 pb-12 animate-in fade-in duration-300">
      
      {/* Splits Header */}
      <div className="flex items-center justify-between bg-[#0E1626]/60 border border-slate-900 rounded-3xl p-4 backdrop-blur-md">
        <div>
          <span className="text-[10px] font-extrabold text-rose-400 tracking-widest uppercase block mb-0.5">Physical Conditioning</span>
          <h1 className="text-2xl font-black text-white tracking-tight flex items-center gap-1">ATHLETICS</h1>
        </div>
      </div>

      {/* Weekdays selector chips */}
      <div className="flex gap-1.5 overflow-x-auto pb-1 -mx-4 px-4 scrollbar-none">
        {[
          { idx: 1, name: "Mon" },
          { idx: 2, name: "Tue" },
          { idx: 3, name: "Wed" },
          { idx: 4, name: "Thu" },
          { idx: 5, name: "Fri" },
          { idx: 6, name: "Sat" },
          { idx: 7, name: "Sun" }
        ].map(day => {
          const split = days.find(d => d.day_index === day.idx);
          const isSelected = selectedIdx === day.idx;

          return (
            <button
              key={day.idx}
              onClick={() => { playTone(600, 0.05, 'triangle'); setSelectedIdx(day.idx); }}
              className={`flex-1 min-w-[50px] py-2.5 rounded-2xl border text-center transition-all ${
                isSelected 
                  ? 'bg-rose-500 border-rose-500 text-slate-950 font-black shadow-lg shadow-rose-500/20' 
                  : split 
                    ? 'bg-slate-900 border-rose-500/25 text-rose-400' 
                    : 'bg-slate-950/40 border-slate-900 text-slate-500'
              }`}
            >
              <p className="text-[10px] uppercase font-black tracking-wider">{day.name}</p>
              <div className={`w-1.5 h-1.5 mx-auto mt-1 rounded-full ${split ? 'bg-rose-500' : 'bg-transparent'}`} />
            </button>
          );
        })}
      </div>

      {/* Workout split builders */}
      <div className="bg-[#0E1626] border border-slate-850 rounded-3xl p-5 shadow-xl space-y-4">
        <div className="flex justify-between items-center border-b border-slate-800 pb-2">
          <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-widest block">Configured Split Day</span>
          <button 
            onClick={() => { playTone(740, 0.08, 'sine'); setShowBuilder(!showBuilder); }}
            className="text-[9px] bg-slate-950 hover:bg-slate-900 text-slate-300 border border-slate-800 px-2.5 py-1.5 rounded-xl font-bold transition-all"
          >
            {showBuilder ? "Cancel" : "Build Custom Split"}
          </button>
        </div>

        {showBuilder && (
          <div className="space-y-4 bg-slate-950/80 p-4 rounded-2xl border border-slate-850 animate-in slide-in-from-bottom duration-200">
            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest block mb-1">Target Weekday</label>
                <select
                  value={builderDay}
                  onChange={e => setBuilderDay(parseInt(e.target.value))}
                  className="w-full text-xs bg-[#0E1626] border border-slate-800 rounded-xl p-2.5 text-slate-200 focus:outline-none"
                >
                  <option value={1}>Monday</option>
                  <option value={2}>Tuesday</option>
                  <option value={3}>Wednesday</option>
                  <option value={4}>Thursday</option>
                  <option value={5}>Friday</option>
                  <option value={6}>Saturday</option>
                  <option value={7}>Sunday</option>
                </select>
              </div>
              <div>
                <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest block mb-1">Workout Label</label>
                <input 
                  type="text" 
                  value={builderLabel} 
                  onChange={e => setBuilderLabel(e.target.value)}
                  placeholder="E.g., Pull Split, Leg Hypertrophy" 
                  className="w-full text-xs bg-[#0E1626] border border-slate-800 rounded-xl p-2 text-slate-200 focus:outline-none"
                />
              </div>
            </div>

            <div>
              <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest block mb-1">Conditioning Notes</label>
              <input 
                type="text" 
                value={builderDesc} 
                onChange={e => setBuilderDesc(e.target.value)}
                placeholder="E.g., Strength development cycle" 
                className="w-full text-xs bg-[#0E1626] border border-slate-800 rounded-xl p-2 text-slate-200 focus:outline-none"
              />
            </div>

            {/* Exercise adding */}
            <div className="p-3 bg-slate-900/60 border border-slate-850 rounded-xl space-y-2.5">
              <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest block">Add Exercise Items</span>
              <input 
                type="text" 
                value={exName} 
                onChange={e => setExName(e.target.value)}
                placeholder="Exercise Name" 
                className="w-full text-xs bg-slate-950 border border-slate-800 rounded-lg p-2 text-slate-200 focus:outline-none"
              />
              <div className="grid grid-cols-2 gap-2">
                <input 
                  type="number" 
                  value={exSets} 
                  onChange={e => setExSets(e.target.value)}
                  placeholder="Sets" 
                  className="w-full text-xs bg-slate-950 border border-slate-800 rounded-lg p-2 text-slate-200 focus:outline-none"
                />
                <input 
                  type="text" 
                  value={exReps} 
                  onChange={e => setExReps(e.target.value)}
                  placeholder="Reps (e.g. 10-12)" 
                  className="w-full text-xs bg-slate-950 border border-slate-800 rounded-lg p-2 text-slate-200 focus:outline-none"
                />
              </div>
              <button 
                onClick={addExerciseToDraft} 
                className="w-full py-1.5 bg-slate-950 border border-slate-800 text-[10px] font-bold text-slate-300 uppercase hover:text-white transition-all"
              >
                + Append Exercise
              </button>

              {builderExercises.length > 0 && (
                <div className="space-y-1.5 pt-2 border-t border-slate-800">
                  {builderExercises.map((ex, i) => (
                    <div key={i} className="flex justify-between items-center text-[10px] text-slate-400 bg-slate-950 p-1.5 rounded border border-slate-800">
                      <span>{ex.name} ({ex.sets} sets × {ex.reps})</span>
                      <button onClick={() => setBuilderExercises(builderExercises.filter((_, idx) => idx !== i))}>
                        <X className="w-3.5 h-3.5 text-rose-400" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <button 
              onClick={handleCreateCustomSplit} 
              className="w-full py-2.5 bg-rose-500 hover:bg-rose-600 text-slate-950 font-black rounded-xl text-xs uppercase shadow-lg shadow-rose-500/20"
            >
              Deploy Split Setup
            </button>
          </div>
        )}

        {/* Workout Exercise Map */}
        {selectedDayPlan ? (
          <div className="space-y-4">
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-sm font-black text-white">{selectedDayPlan.label}</h3>
                <p className="text-[10px] text-slate-400 mt-0.5">{selectedDayPlan.description}</p>
              </div>
              <button 
                onClick={() => deleteSplitPlan(selectedDayPlan.id)}
                className="text-[10px] text-rose-400 font-black hover:underline"
              >
                Delete Split
              </button>
            </div>

            <div className="space-y-2">
              {selectedDayPlan.exercises?.length === 0 && (
                <p className="text-xs text-slate-500 italic py-4 text-center">No exercises configured in split.</p>
              )}
              {selectedDayPlan.exercises?.map((ex, i) => (
                <button
                  key={i}
                  onClick={() => toggleExerciseStatus(selectedDayPlan.id, i)}
                  className="w-full flex items-center gap-3 p-3 bg-slate-950/60 rounded-2xl border border-slate-850 hover:bg-slate-950 text-left transition-all"
                >
                  <span className={`w-5 h-5 rounded-md border-2 flex items-center justify-center flex-shrink-0 transition-all ${
                    ex.completed ? 'bg-rose-500 border-rose-500 text-slate-950' : 'border-slate-700'
                  }`}>
                    {ex.completed && <Check className="w-3.5 h-3.5 stroke-[4]" />}
                  </span>

                  <div>
                    <p className={`text-xs font-bold text-white ${ex.completed ? 'line-through text-slate-500' : ''}`}>{ex.name}</p>
                    <p className="text-[10px] text-slate-400 mt-0.5">Sets: {ex.sets} × Reps: {ex.reps}</p>
                  </div>
                </button>
              ))}
            </div>
          </div>
        ) : (
          <div className="text-center py-8 bg-slate-950/60 rounded-3xl border border-slate-900/60 space-y-2">
            <p className="text-xs text-slate-500 italic">No scheduled routine assigned for this weekday.</p>
            <p className="text-[9px] text-slate-600">Activate Split Builder above to configure custom exercises.</p>
          </div>
        )}

      </div>

    </div>
  );
}

function Fencing({ triggerToast }) {
  const [tasks, setTasks] = useState([]);
  const [adding, setAdding] = useState(false);
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('Footwork');
  const [duration, setDuration] = useState(15);
  const [notes, setNotes] = useState('');

  const [customCategories, setCustomCategories] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('custom_fencing_categories')) || [];
    } catch {
      return [];
    }
  });
  const [showCategoryCreator, setShowCategoryCreator] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState('');

  const [runningDrill, setRunningDrill] = useState(null);
  const [drillTimeLeft, setDrillTimeLeft] = useState(60);
  const [drillRunning, setDrillRunning] = useState(false);
  const drillTimerRef = useRef(null);

  const today = todayStr();

  const loadFencingTasks = useCallback(() => {
    const list = db.get('fencing_drills', []).filter(item => item.date === today);
    setTasks(list);
  }, [today]);

  useEffect(() => {
    loadFencingTasks();
  }, [loadFencingTasks]);

  useEffect(() => {
    if (drillRunning) {
      drillTimerRef.current = setInterval(() => {
        setDrillTimeLeft(prev => {
          if (prev <= 1) {
            handleDrillFinish();
            return 0;
          }
          if (prev % 5 === 0) playTone(980, 0.05, 'sine', 0.03);
          return prev - 1;
        });
      }, 1000);
    } else {
      clearInterval(drillTimerRef.current);
    }
    return () => clearInterval(drillTimerRef.current);
  }, [drillRunning]);

  const handleDrillFinish = () => {
    setDrillRunning(false);
    triggerToast("Interval drill complete! Return to stance.");
    playTone(1200, 0.45, 'sine');
    setTimeout(() => playTone(1200, 0.35, 'sine'), 150);
  };

  const startStopwatchDrill = (presetSec, label) => {
    setRunningDrill(label);
    setDrillTimeLeft(presetSec);
    setDrillRunning(true);
    playTone(660, 0.15, 'triangle');
  };

  const handleCreateCategory = () => {
    const trimmed = newCategoryName.trim();
    if (!trimmed) return;
    const exists = DEFAULT_FENCING_CATEGORIES.includes(trimmed) || customCategories.includes(trimmed);
    if (exists) {
      triggerToast("Category classification already exists.");
      return;
    }

    const list = [...customCategories, trimmed];
    localStorage.setItem('custom_fencing_categories', JSON.stringify(list));
    setCustomCategories(list);
    setCategory(trimmed);
    setNewCategoryName('');
    setShowCategoryCreator(false);
    playTone(1050, 0.1, 'sine');
  };

  const toggleTaskStatus = (task) => {
    const list = db.get('fencing_drills', []);
    const updated = list.map(item => item.id === task.id ? { ...item, completed: !item.completed } : item);
    db.set('fencing_drills', updated);
    playTone(1100, 0.08, 'sine');
    loadFencingTasks();
  };

  const removeFencingTask = (id) => {
    const list = db.get('fencing_drills', []);
    const updated = list.filter(item => item.id !== id);
    db.set('fencing_drills', updated);
    playTone(180, 0.15, 'sawtooth');
    loadFencingTasks();
  };

  const addFencingTask = () => {
    if (!title.trim()) return;
    const list = db.get('fencing_drills', []);
    list.push({
      id: 'fencing_' + Date.now() + Math.random(),
      title: title.trim(),
      category,
      duration_minutes: parseInt(duration) || 0,
      notes: notes.trim(),
      completed: false,
      date: today
    });
    db.set('fencing_drills', list);
    setTitle('');
    setNotes('');
    setAdding(false);
    playTone(1100, 0.1, 'sine');
    loadFencingTasks();
  };

  return (
    <div className="max-w-md mx-auto px-4 pt-6 space-y-6 pb-12 animate-in fade-in duration-300">
      
      {/* Tactical fencing headers */}
      <div className="flex items-center justify-between bg-[#0E1626]/60 border border-slate-900 rounded-3xl p-4 backdrop-blur-md">
        <div>
          <span className="text-[10px] font-extrabold text-amber-400 tracking-widest uppercase block mb-0.5">Tactical Sparring</span>
          <h1 className="text-2xl font-black text-white tracking-tight flex items-center gap-1">FENCING</h1>
        </div>

        <button 
          onClick={() => { playTone(740, 0.08, 'sine'); setAdding(!adding); }}
          className="text-xs bg-amber-500/15 hover:bg-amber-500/20 text-amber-400 border border-amber-500/25 px-3 py-1.5 rounded-xl font-black uppercase tracking-widest"
        >
          Schedule Drill
        </button>
      </div>

      {/* Stopwatch Coaching Interval workstation */}
      <div className="bg-[#0E1626] border border-slate-850 rounded-3xl p-5 shadow-2xl space-y-4">
        <div>
          <h2 className="text-xs font-black text-slate-300 uppercase tracking-wider flex items-center gap-2">
            <Sword className="w-4 h-4 text-amber-500" /> Strip Interval Coach
          </h2>
          <p className="text-[10px] text-slate-500 mt-1 leading-relaxed">
            Manage guard stance hold times, lunge speed sets, or blades parry tactical drills.
          </p>
        </div>

        <div className="bg-slate-950 p-4 rounded-2xl border border-slate-850 flex items-center justify-between">
          <div>
            <span className="text-[8px] bg-amber-500/15 text-amber-400 border border-amber-500/20 px-1.5 py-0.5 rounded font-bold uppercase">
              {runningDrill ? `Active: ${runningDrill}` : 'Standby'}
            </span>
            <div className="text-3xl font-black font-mono text-white tracking-tight mt-1">
              {Math.floor(drillTimeLeft / 60)}:{(drillTimeLeft % 60).toString().padStart(2, '0')}
            </div>
          </div>

          <div className="flex gap-2">
            <button 
              onClick={() => setDrillRunning(!drillRunning)}
              className={`p-2.5 rounded-xl text-xs font-bold transition-all ${
                drillRunning ? 'bg-amber-500 text-slate-950 font-black' : 'bg-slate-900 border border-slate-800 text-slate-300 hover:text-white'
              }`}
            >
              {drillRunning ? 'Pause' : 'Resume'}
            </button>
            <button 
              onClick={() => { setDrillRunning(false); setDrillTimeLeft(60); setRunningDrill(null); }}
              className="p-2.5 bg-slate-900 border border-slate-800 hover:border-slate-700 text-slate-500 hover:text-white rounded-xl transition-all"
            >
              Reset
            </button>
          </div>
        </div>

        {/* Coach templates */}
        <div className="grid grid-cols-3 gap-2">
          {[
            { label: 'Guard Hold', time: 60, desc: '60s hold stance' },
            { label: 'Thrust Sets', time: 120, desc: '2m point control' },
            { label: 'Bout Tactics', time: 180, desc: '3m tactical spar' }
          ].map(p => (
            <button
              key={p.label}
              onClick={() => startStopwatchDrill(p.time, p.label)}
              className="bg-slate-950/60 hover:bg-slate-950 border border-slate-850 p-2.5 rounded-xl text-left transition-all"
            >
              <p className="text-[9px] font-black text-slate-300 uppercase tracking-wider">{p.label}</p>
              <p className="text-[8px] text-slate-500 font-bold mt-0.5">{p.desc}</p>
            </button>
          ))}
        </div>
      </div>

      {adding && (
        <div className="bg-[#0E1626] border border-slate-850 p-4 rounded-3xl space-y-3 animate-in slide-in-from-top duration-200">
          <div className="space-y-1">
            <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest block">Drill Title</label>
            <input 
              type="text" 
              value={title} 
              onChange={e => setTitle(e.target.value)}
              placeholder="E.g., Practice parry-riposte sequence..." 
              className="w-full text-xs bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-slate-200 focus:outline-none focus:border-amber-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <div className="flex justify-between items-center">
                <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Category</label>
                <button onClick={() => setShowCategoryCreator(!showCategoryCreator)} className="text-[8px] text-amber-400 font-bold">+ Custom</button>
              </div>

              {showCategoryCreator ? (
                <div className="p-2 bg-slate-950 border border-slate-800 rounded-lg space-y-2">
                  <input 
                    placeholder="New Category Name" 
                    value={newCategoryName} 
                    onChange={e => setNewCategoryName(e.target.value)}
                    className="w-full text-[9px] bg-[#0E1626] border border-slate-800 text-slate-200 p-1 rounded focus:outline-none" 
                  />
                  <button onClick={handleCreateCategory} className="w-full text-[9px] bg-amber-500 py-1 rounded text-slate-950 font-bold">Add</button>
                </div>
              ) : (
                <select
                  value={category}
                  onChange={e => setCategory(e.target.value)}
                  className="w-full text-xs bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-slate-200 focus:outline-none"
                >
                  {DEFAULT_FENCING_CATEGORIES.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                  {customCategories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                </select>
              )}
            </div>

            <div className="space-y-1">
              <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest block">Duration (Mins)</label>
              <input 
                type="number" 
                value={duration} 
                onChange={e => setDuration(parseInt(e.target.value) || 0)}
                className="w-full text-xs bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-slate-200 focus:outline-none"
              />
            </div>
          </div>

          <div className="space-y-1">
            <label className="text-[9px] font-bold text-slate-500 uppercase tracking-widest block">Tactical Foil Notes</label>
            <input 
              type="text" 
              value={notes} 
              onChange={e => setNotes(e.target.value)}
              placeholder="Notes on point pressure, recovery step..." 
              className="w-full text-xs bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-slate-200 focus:outline-none"
            />
          </div>

          <button 
            onClick={addFencingTask} 
            className="w-full py-2 bg-amber-500 hover:bg-amber-600 text-slate-950 font-black rounded-xl text-xs uppercase shadow-lg shadow-amber-500/20"
          >
            Deploy Drill Objective
          </button>
        </div>
      )}

      {/* Drill task list map */}
      <div className="space-y-2">
        {tasks.length === 0 && (
          <p className="text-xs text-slate-500 italic py-4 text-center bg-slate-950/60 rounded-3xl border border-slate-900/60">
            No fencing drills logged today. Setup tasks above!
          </p>
        )}
        {tasks.map(t => (
          <div 
            key={t.id} 
            className={`p-3 bg-slate-950/60 hover:bg-slate-950 border rounded-2xl flex items-center justify-between transition-all ${
              t.completed ? 'border-emerald-500/10 opacity-60' : 'border-slate-850'
            }`}
          >
            <div className="flex items-center gap-3 flex-1 min-w-0">
              <button 
                onClick={() => toggleTaskStatus(t)} 
                className={`w-5 h-5 rounded-md border flex items-center justify-center flex-shrink-0 transition-all ${
                  t.completed ? 'bg-emerald-500 border-emerald-500 text-[#0A0F1D]' : 'border-slate-700'
                }`}
              >
                {t.completed && <Check className="w-3.5 h-3.5 stroke-[4]" />}
              </button>

              <div className="flex-1 min-w-0">
                <p className={`text-xs font-bold text-white truncate ${t.completed ? 'line-through text-slate-500' : ''}`}>{t.title}</p>
                <div className="flex items-center gap-1.5 mt-1">
                  <span className="text-[8px] font-black bg-slate-900 border border-slate-800 text-slate-400 px-1.5 py-0.5 rounded uppercase">
                    {t.category}
                  </span>
                  <span className="text-[8px] text-amber-400 font-medium font-mono">
                    ⏱️ {t.duration_minutes} mins
                  </span>
                  {t.notes && <span className="text-[8px] text-slate-500 truncate max-w-[120px]">({t.notes})</span>}
                </div>
              </div>
            </div>

            <button onClick={() => removeFencingTask(t.id)} className="p-1.5 text-slate-600 hover:text-rose-500 transition-colors ml-2">
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>

    </div>
  );
}

function Progress({ triggerToast }) {
  const [metrics, setMetrics] = useState([]);
  const [weightInput, setWeightInput] = useState('');
  const [heightInput, setHeightInput] = useState('');
  const [taskReviews, setTaskReviews] = useState([]);

  useEffect(() => {
    const loadTelemetry = () => {
      setMetrics(db.get('body_metrics', []));
      setTaskReviews(db.get('task_reviews', []));
    };
    loadTelemetry();
  }, []);

  const addNewMetricLog = () => {
    if (!weightInput.trim()) return;
    const list = db.get('body_metrics', []);
    const updated = [...list, {
      weight_kg: parseFloat(weightInput),
      height_cm: heightInput ? parseFloat(heightInput) : 180,
      date: todayStr()
    }];
    db.set('body_metrics', updated);
    setWeightInput('');
    setHeightInput('');
    playTone(1350, 0.15, 'sine');
    setMetrics(updated);
    triggerToast("Biometric parameters updated.");
  };

  const removeReviewLog = (id) => {
    const list = db.get('task_reviews', []);
    const updated = list.filter(item => item.id !== id);
    db.set('task_reviews', updated);
    playTone(180, 0.15, 'sawtooth');
    setTaskReviews(updated);
  };

  const svgW = 400;
  const svgH = 150;
  const weights = metrics.map(m => m.weight_kg);
  const minW = weights.length > 0 ? Math.min(...weights, 70) - 2 : 60;
  const maxW = weights.length > 0 ? Math.max(...weights, 80) + 2 : 90;

  const points = metrics.map((m, idx) => {
    const x = metrics.length > 1 ? (idx / (metrics.length - 1)) * (svgW - 50) + 25 : svgW / 2;
    const y = maxW !== minW ? svgH - 25 - ((m.weight_kg - minW) / (maxW - minW)) * (svgH - 50) : svgH / 2;
    return { x, y, val: m.weight_kg, date: m.date };
  });

  const pathPoints = points.map(p => `${p.x},${p.y}`).join(' ');

  return (
    <div className="max-w-md mx-auto px-4 pt-6 space-y-6 pb-12 animate-in fade-in duration-300">
      
      {/* Analytics header */}
      <div className="flex items-center justify-between bg-[#0E1626]/60 border border-slate-900 rounded-3xl p-4 backdrop-blur-md">
        <div>
          <span className="text-[10px] font-extrabold text-emerald-400 tracking-widest uppercase block mb-0.5">Biometric Systems</span>
          <h1 className="text-2xl font-black text-white tracking-tight flex items-center gap-1">ANALYTICS</h1>
        </div>
      </div>

      {/* Weight composition plot card */}
      <div className="bg-[#0E1626] border border-slate-850 rounded-3xl p-5 shadow-2xl space-y-4">
        <div>
          <h2 className="text-xs font-black text-slate-300 uppercase tracking-wider flex items-center gap-2">
            <Scale className="w-4 h-4 text-emerald-400" /> Body Composition Telemetry
          </h2>
          <p className="text-[10px] text-slate-500 mt-1 leading-relaxed">
            Verify training progress trends through weekly mass metrics logs.
          </p>
        </div>

        {metrics.length > 1 ? (
          <div className="my-4 bg-slate-950/60 p-3 rounded-2xl border border-slate-850">
            <svg viewBox={`0 0 ${svgW} ${svgH}`} className="w-full h-auto">
              <line x1="20" y1="125" x2="380" y2="125" stroke="#1E293B" strokeWidth="1" strokeDasharray="3 3" />
              <line x1="20" y1="25" x2="380" y2="25" stroke="#1E293B" strokeWidth="1" strokeDasharray="3 3" />

              <polyline fill="none" stroke="#10B981" strokeWidth="3" points={pathPoints} strokeLinecap="round" />

              {points.map((p, i) => (
                <g key={i} className="group cursor-pointer">
                  <circle cx={p.x} cy={p.y} r="5" fill="#10B981" className="hover:scale-125 transition-all" />
                  <text x={p.x} y={p.y - 8} fill="#ffffff" fontSize="8" fontWeight="bold" textAnchor="middle">
                    {p.val}
                  </text>
                  <text x={p.x} y="145" fill="#64748b" fontSize="7" textAnchor="middle">
                    {p.date.slice(5)}
                  </text>
                </g>
              ))}
            </svg>
          </div>
        ) : (
          <p className="text-xs text-slate-500 italic py-8 text-center bg-slate-950/60 border border-slate-900/60 rounded-2xl">
            Awaiting additional weekly composition entries to generate trend plot graphs...
          </p>
        )}

        <div className="grid grid-cols-2 gap-2 bg-slate-950/40 p-3.5 rounded-2xl border border-slate-850">
          <div className="space-y-1">
            <label className="text-[8px] font-extrabold text-slate-500 uppercase tracking-widest block">Mass Weight (kg)</label>
            <input 
              type="number" 
              step="0.1" 
              value={weightInput} 
              onChange={e => setWeightInput(e.target.value)}
              placeholder="e.g., 74.2" 
              className="w-full text-xs bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-slate-200 focus:outline-none"
            />
          </div>
          <div className="space-y-1">
            <label className="text-[8px] font-extrabold text-slate-500 uppercase tracking-widest block">Height (cm)</label>
            <input 
              type="number" 
              step="0.1" 
              value={heightInput} 
              onChange={e => setHeightInput(e.target.value)}
              placeholder="e.g., 182" 
              className="w-full text-xs bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-slate-200 focus:outline-none"
            />
          </div>
        </div>

        <button 
          onClick={addNewMetricLog} 
          className="w-full py-2 bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-black rounded-xl text-xs uppercase"
        >
          Add Measurement
        </button>
      </div>

      {/* Task deferral reflections archive */}
      <div className="bg-[#0E1626] border border-slate-850 rounded-3xl p-5 shadow-2xl space-y-4">
        <div>
          <h2 className="text-xs font-black text-slate-300 uppercase tracking-wider flex items-center gap-2">
            <History className="w-4 h-4 text-violet-500" /> Audited Reflections Archive
          </h2>
          <p className="text-[10px] text-slate-500 mt-1 leading-relaxed">
            Examine critical reflection comments written during end-of-day workflow audits.
          </p>
        </div>

        <div className="space-y-2">
          {taskReviews.length === 0 && (
            <p className="text-xs text-slate-500 italic py-4 text-center bg-slate-950/60 border border-slate-900/60 rounded-2xl">
              Reflection archive clean. Perfect execution maintained.
            </p>
          )}
          {taskReviews.map((rev, index) => (
            <div key={index} className="p-3.5 bg-slate-950/60 rounded-2xl border border-slate-850 space-y-2">
              <div className="flex justify-between items-start">
                <div>
                  <span className="text-[8px] bg-slate-900 border border-slate-800 text-rose-400 px-2 py-0.5 rounded font-black uppercase tracking-wider">
                    {rev.task_type} Deferred
                  </span>
                  <h4 className="text-xs font-black text-white mt-1.5">{rev.task_title}</h4>
                </div>
                <button onClick={() => removeReviewLog(rev.id)} className="text-slate-600 hover:text-rose-500 transition-colors">
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              <div className="p-2.5 bg-[#0E1626]/80 rounded-xl border border-slate-850">
                <p className="text-[10px] text-slate-400 italic">" {rev.reason} "</p>
              </div>

              <div className="text-[8px] text-slate-500 text-right font-mono font-medium">Logged: {rev.date}</div>
            </div>
          ))}
        </div>
      </div>

    </div>
  );
}

function Settings({ triggerToast }) {
  const [morningEnabled, setMorningEnabled] = useState(true);
  const [morningTime, setMorningTime] = useState('08:00');
  const [eveningEnabled, setEveningEnabled] = useState(true);
  const [eveningTime, setEveningTime] = useState('22:00');
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [audioVolume, setAudioVolume] = useState(0.08);

  useEffect(() => {
    try {
      const s = db.get('settings_config', {});
      setMorningEnabled(s.morning?.enabled !== false);
      setMorningTime(s.morning?.time || '08:00');
      setEveningEnabled(s.evening?.enabled !== false);
      setEveningTime(s.evening?.time || '22:00');
      
      const config = db.get('settings', {});
      setSoundEnabled(config.sound !== false);
      setAudioVolume(config.volume || 0.08);
    } catch (e) {
      // safe fallbacks
    }
  }, []);

  const saveSettings = (key, val, val2) => {
    try {
      const s = db.get('settings_config', {});
      s[key] = { enabled: val, time: val2 };
      db.set('settings_config', s);
    } catch (e) {}
  };

  const handleTestTone = () => {
    playTone(660, 0.2, 'sawtooth', audioVolume);
    setTimeout(() => playTone(880, 0.15, 'sawtooth', audioVolume), 120);
    setTimeout(() => playTone(1046, 0.35, 'triangle', audioVolume), 240);
  };

  const clearDatabaseTelemetry = () => {
    localStorage.clear();
    playTone(180, 0.3, 'sawtooth');
    triggerToast("Local storage data cleared.");
    setTimeout(() => {
      window.location.reload();
    }, 1500);
  };

  return (
    <div className="max-w-md mx-auto px-4 pt-6 space-y-6 pb-12 animate-in fade-in duration-300">
      
      {/* Settings header */}
      <div className="flex items-center justify-between bg-[#0E1626]/60 border border-slate-900 rounded-3xl p-4 backdrop-blur-md">
        <div>
          <span className="text-[10px] font-extrabold text-slate-400 tracking-widest uppercase block mb-0.5">Control Hub</span>
          <h1 className="text-2xl font-black text-white tracking-tight flex items-center gap-1">SETTINGS</h1>
        </div>
      </div>

      <div className="bg-[#0E1626] border border-slate-850 rounded-3xl p-5 shadow-2xl space-y-4">
        <div>
          <h2 className="text-xs font-black text-slate-300 uppercase tracking-wider flex items-center gap-2">
            <Bell className="w-4 h-4 text-violet-400" /> Alarm Reminder Matrix
          </h2>
          <p className="text-[10px] text-slate-500 mt-1 leading-relaxed">
            Calibrate core checklist triggers, session diagnostics, and alarm oscillators.
          </p>
        </div>

        {/* Morning trigger layout parameters setting */}
        <div className="p-4 bg-slate-950 rounded-2xl border border-slate-850 space-y-3">
          <div className="flex justify-between items-center">
            <div className="space-y-0.5">
              <p className="text-xs font-black text-white flex items-center gap-1.5 uppercase">
                <Sun className="w-4 h-4 text-amber-400" /> Morning Checklist Alarm
              </p>
              <p className="text-[10px] text-slate-500">Triggers planning workflow setups</p>
            </div>
            <input 
              type="checkbox" 
              checked={morningEnabled}
              onChange={e => { setMorningEnabled(e.target.checked); saveSettings('morning', e.target.checked, morningTime); }}
              className="w-4 h-4 rounded text-violet-600 focus:ring-violet-500 bg-slate-900 border-slate-800"
            />
          </div>

          {morningEnabled && (
            <div className="space-y-1">
              <label className="text-[8px] font-extrabold text-slate-500 uppercase tracking-widest">Alarm Time</label>
              <input 
                type="time" 
                value={morningTime} 
                onChange={e => { setMorningTime(e.target.value); saveSettings('morning', morningEnabled, e.target.value); }}
                className="text-xs bg-[#0E1626] border border-slate-800 rounded-lg p-2 text-slate-200 focus:outline-none"
              />
            </div>
          )}
        </div>

        {/* Reflection triggers configuration settings */}
        <div className="p-4 bg-slate-950 rounded-2xl border border-slate-850 space-y-3">
          <div className="flex justify-between items-center">
            <div className="space-y-0.5">
              <p className="text-xs font-black text-white flex items-center gap-1.5 uppercase">
                <Moon className="w-4 h-4 text-rose-400" /> Audited Reflections Review
              </p>
              <p className="text-[10px] text-slate-500">Prompts logs for missed objectives</p>
            </div>
            <input 
              type="checkbox" 
              checked={eveningEnabled}
              onChange={e => { setEveningEnabled(e.target.checked); saveSettings('evening', e.target.checked, eveningTime); }}
              className="w-4 h-4 rounded text-violet-600 focus:ring-violet-500 bg-slate-900 border-slate-800"
            />
          </div>

          {eveningEnabled && (
            <div className="space-y-1">
              <label className="text-[8px] font-extrabold text-slate-500 uppercase tracking-widest">Alarm Time</label>
              <input 
                type="time" 
                value={eveningTime} 
                onChange={e => { setEveningTime(e.target.value); saveSettings('evening', eveningEnabled, e.target.value); }}
                className="text-xs bg-[#0E1626] border border-slate-800 rounded-lg p-2 text-slate-200 focus:outline-none"
              />
            </div>
          )}
        </div>

        {/* Browser native audio synthesizer alert settings */}
        <div className="p-4 bg-slate-950 rounded-2xl border border-slate-850 space-y-3">
          <div className="flex justify-between items-center">
            <div className="space-y-0.5">
              <p className="text-xs font-black text-white flex items-center gap-1.5 uppercase">
                <Volume2 className="w-4 h-4 text-slate-400" /> Synthesizer Sound
              </p>
              <p className="text-[10px] text-slate-500">Alert oscillators volume setting</p>
            </div>
            <input 
              type="checkbox" 
              checked={soundEnabled}
              onChange={e => {
                setSoundEnabled(e.target.checked);
                db.set('settings', { sound: e.target.checked, volume: audioVolume });
              }}
              className="w-4 h-4 rounded text-violet-600 focus:ring-violet-500 bg-slate-900 border-slate-800"
            />
          </div>

          {soundEnabled && (
            <div className="space-y-1">
              <div className="flex justify-between text-[10px] text-slate-500">
                <span>Alert Volume: {Math.round(audioVolume * 100)}%</span>
              </div>
              <input 
                type="range" 
                min="0.01" 
                max="0.2" 
                step="0.01" 
                value={audioVolume} 
                onChange={e => {
                  setAudioVolume(parseFloat(e.target.value));
                  db.set('settings', { sound: soundEnabled, volume: parseFloat(e.target.value) });
                }}
                className="w-full h-1.5 bg-[#0E1626] rounded-lg appearance-none cursor-pointer accent-violet-600"
              />
            </div>
          )}
        </div>

        <div className="grid grid-cols-2 gap-2 pt-2">
          <button 
            onClick={handleTestTone}
            className="py-3 bg-slate-950 border border-slate-800 hover:border-slate-700 text-slate-300 hover:text-white rounded-xl text-[10px] font-black uppercase tracking-widest transition-all"
          >
            🔊 Test Alarm Tone
          </button>
          <button 
            onClick={clearDatabaseTelemetry}
            className="py-3 bg-slate-950 border border-slate-800 hover:border-rose-900 text-rose-400 hover:text-rose-300 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all"
          >
            🔄 Wipe Database
          </button>
        </div>
      </div>

    </div>
  );
}
