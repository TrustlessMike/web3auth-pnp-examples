import "./App.css";

import { Web3AuthProvider } from "@web3auth/modal-react-hooks";
import React from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";

import { chain } from "./config/chainConfig";
import Contract from "./pages/Contract";
import HomePage from "./pages/HomePage";
// import NFT from "./pages/NFT";
import ServerSideVerification from "./pages/ServerSideVerification";
import Transaction from "./pages/Transaction";
import { Playground } from "./services/playground";
import web3AuthContextConfig from "./services/web3authContext";

function App() {
  return (
    <div>
      <Web3AuthProvider config={web3AuthContextConfig}>
        <Playground>
          <BrowserRouter>
            <Routes>
              <Route path="/">
                <Route index element={<HomePage />} />
                <Route path="contract" element={<Contract />} />
                <Route path="transaction" element={<Transaction />} />
                <Route path="server-side-verification" element={<ServerSideVerification />} />
              </Route>
            </Routes>
          </BrowserRouter>
        </Playground>
      </Web3AuthProvider>
    </div>
  );
}

export default App;
