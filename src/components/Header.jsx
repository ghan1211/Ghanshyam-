import React from 'react'

export default function Header () {
  return (
    <header style={{display: 'flex', alignItems: 'center', gap: 16}}>
      <img src="/favicon.svg" alt="logo" width="48" height="48" />
      <div>
        <h1 style={{margin: 0}}>Ghanshyam — Academic Athlete Deck</h1>
        <p style={{margin: 0, color: '#6b7280'}}>A small offline-capable planner</p>
      </div>
    </header>
  )
}
