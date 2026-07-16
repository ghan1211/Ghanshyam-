import React, { useState, useEffect } from 'react'
import Header from './components/Header'
import TaskForm from './components/TaskForm'
import TaskList from './components/TaskList'
import { loadTasks, saveTasks } from './utils/storage'

export default function App () {
  const [tasks, setTasks] = useState([])
  const [filter, setFilter] = useState('all')

  useEffect(() => {
    let mounted = true
    loadTasks().then(stored => {
      if (mounted && stored) setTasks(stored)
    })
    return () => { mounted = false }
  }, [])

  useEffect(() => {
    saveTasks(tasks).catch(err => console.error('Failed to save tasks', err))
  }, [tasks])

  function addTask (title, due) {
    const id = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : String(Date.now())
    const newTask = { id, title, due: due || null, completed: false, createdAt: Date.now() }
    setTasks(prev => [newTask, ...prev])
  }

  function toggleTask (id) {
    setTasks(prev => prev.map(t => t.id === id ? { ...t, completed: !t.completed } : t))
  }

  function updateTask (id, updates) {
    setTasks(prev => prev.map(t => t.id === id ? { ...t, ...updates } : t))
  }

  function deleteTask (id) {
    setTasks(prev => prev.filter(t => t.id !== id))
  }

  const filteredTasks = tasks.filter(t => {
    if (filter === 'active') return !t.completed
    if (filter === 'completed') return t.completed
    return true
  })

  return (
    <div style={{maxWidth: 900, margin: '36px auto', padding: 20}}>
      <Header />

      <section style={{marginTop: 20}}>
        <TaskForm onAdd={addTask} />
      </section>

      <section style={{marginTop: 24}}>
        <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center'}}>
          <h2 style={{margin: 0}}>Tasks</h2>
          <div>
            <button onClick={() => setFilter('all')} style={{marginRight: 8, opacity: filter === 'all' ? 1 : 0.6}}>All</button>
            <button onClick={() => setFilter('active')} style={{marginRight: 8, opacity: filter === 'active' ? 1 : 0.6}}>Active</button>
            <button onClick={() => setFilter('completed')} style={{opacity: filter === 'completed' ? 1 : 0.6}}>Completed</button>
          </div>
        </div>

        <TaskList
          tasks={filteredTasks}
          onToggle={toggleTask}
          onDelete={deleteTask}
          onUpdate={updateTask}
        />

        <footer style={{marginTop: 16, color: '#6b7280'}}>
          {tasks.length} total • {tasks.filter(t => !t.completed).length} open • {tasks.filter(t => t.completed).length} done
        </footer>
      </section>
    </div>
  )
}
