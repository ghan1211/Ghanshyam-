# Ghanshyam-
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
          
