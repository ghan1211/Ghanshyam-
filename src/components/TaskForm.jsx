import React, { useState } from 'react'

export default function TaskForm ({ onAdd }) {
  const [title, setTitle] = useState('')
  const [due, setDue] = useState('')

  function submit (e) {
    e.preventDefault()
    const trimmed = title.trim()
    if (!trimmed) return
    onAdd(trimmed, due || null)
    setTitle('')
    setDue('')
  }

  return (
    <form onSubmit={submit} style={{display: 'flex', gap: 8, alignItems: 'center'}}>
      <input
        aria-label="Task title"
        placeholder="Add a task, exam or project..."
        value={title}
        onChange={e => setTitle(e.target.value)}
        style={{flex: 1, padding: '8px 12px', borderRadius: 8, border: '1px solid #e5e7eb'}}
      />
      <input
        type="date"
        aria-label="Due date"
        value={due}
        onChange={e => setDue(e.target.value)}
        style={{padding: '8px 12px', borderRadius: 8, border: '1px solid #e5e7eb'}}
      />
      <button type="submit" style={{padding: '8px 12px', borderRadius: 8, background: '#4f46e5', color: 'white', border: 'none'}}>Add</button>
    </form>
  )
}
