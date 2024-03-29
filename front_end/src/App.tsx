import React from 'react';
import './App.css';
import { ChainId, DAppProvider } from '@usedapp/core';
import {Header} from './components/Header'
import { Container } from "@material-ui/core"
import {Main} from "./components/Main"

function App() {
  return (
    <DAppProvider config={{
      supportedChains: [ChainId.Kovan]
    }}>
      <Header/>
      <Container maxWidth="md">
      <div className="App">Hi!</div>
      <Main/>
      </Container>
    </DAppProvider>
    
  );
}

export default App;
