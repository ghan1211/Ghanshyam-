import React, { useState } from 'react'

export default function TaskCard ({ task, onToggle, onDelete, onUpdate }) {
  const [editing, setEditing] = useState(false)
  const [title, setTitle] = useState(task.title)
  const [due, setDue] = useState(task.due || '')

  function save () {
    const trimmed = title.trim()
    if (!trimmed) return
    onUpdate(task.id, { title: trimmed, due: due || null })
    setEditing(false)
  }

  return (
    <article style={{display: 'flex', gap: 12, alignItems: 'center', padding: 12, borderRadius: 10, border: '1px solid #e6e9ef', background: 'white'}}>
      <input type="checkbox" checked={task.completed} onChange={() => onToggle(task.id)} aria-label={`Mark ${task.title} complete`} />

      <div style={{flex: 1}}>
        {!editing ? (
          <div>
            <div style={{fontWeight: 600, textDecoration: task.completed ? 'line-through' : 'none'}}>{task.title}</div>
            {task.due ? <div style={{color: '#6b7280', fontSize: 13}}>Due: {task.due}</div> : null}
          </div>
        ) : (
          <div style={{display: 'flex', gap: 8}}>
            <input value={title} onChange={e => setTitle(e.target.value)} style={{flex: 1, padding: '6px 8px', borderRadius: 6, border: '1px solid #e5e7eb'}} />
            <input type="date" value={due} onChange={e => setDue(e.target.value)} style={{padding: '6px 8px', borderRadius: 6, border: '1px solid #e5e7eb'}} />
          </div>
        )}
      </div>

      <div style={{display: 'flex', gap: 8}}>
        {!editing ? (
          <button onClick={() => setEditing(true)} style={{background: 'transparent', border: 'none', color: '#4f46e5'}}>Edit</button>
        ) : (
          <>
            <button onClick={save} style={{background: '#10b981', color: 'white', border: 'none', padding: '6px 10px', borderRadius: 6}}>Save</button>
            <button onClick={() => { setEditing(false); setTitle(task.title); setDue(task.due || '') }} style={{background: 'transparent', border: 'none'}}>Cancel</button>
          </>
        )}
        <button onClick={() => onDelete(task.id)} style={{background: 'transparent', border: 'none', color: '#ef4444'}}>Delete</button>
      </div>
    </article>
  )
}
