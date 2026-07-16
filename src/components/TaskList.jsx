import React from 'react'
import TaskCard from './TaskCard'

export default function TaskList ({ tasks, onToggle, onDelete, onUpdate }) {
  if (!tasks || tasks.length === 0) return <p style={{marginTop: 12, color: '#6b7280'}}>No tasks yet — add one above.</p>

  return (
    <ul style={{listStyle: 'none', padding: 0, marginTop: 12, display: 'grid', gap: 12}}>
      {tasks.map(task => (
        <li key={task.id}>
          <TaskCard task={task} onToggle={onToggle} onDelete={onDelete} onUpdate={onUpdate} />
        </li>
      ))}
    </ul>
  )
}
