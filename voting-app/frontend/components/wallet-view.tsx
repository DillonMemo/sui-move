"use client";

import WalletStatus from "./wallet/status";

export default function WalletView() {
  return (
    <>
      <div className="mb-8">
        <h1 className="text-4xl md:text-xl font-bold">Your Wallet Info</h1>
        <WalletStatus />
      </div>
    </>
  );
}
