import React from 'react'
import { CssBaseline } from '@mui/material'
import './App.css'
import SeismicEvents from './components/SeismicEvents'

function App() {
  return (
    <>
      <CssBaseline />
      <div className="App">
        <SeismicEvents />
      </div>
    </>
  )
}

export default App
