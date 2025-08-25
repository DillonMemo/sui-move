"use client";

import { DEVNET_DASHBOARD_ID, MAINNET_DASHBOARD_ID, TESTNET_DASHBOARD_ID } from "@/constants";
import { createNetworkConfig, SuiClientProvider, WalletProvider } from "@mysten/dapp-kit";
import { getFullnodeUrl } from "@mysten/sui/client";

export const { networkConfig, useNetworkVariable } = createNetworkConfig({
  devnet: {
    url: getFullnodeUrl("devnet"),
    variables: {
      dashboardId: DEVNET_DASHBOARD_ID,
    },
  },
  testnet: {
    url: getFullnodeUrl("testnet"),
    variables: {
      dashboardId: TESTNET_DASHBOARD_ID,
    },
  },
  mainnet: {
    url: getFullnodeUrl("mainnet"),
    variables: {
      dashboardId: MAINNET_DASHBOARD_ID,
    },
  },
});

export default function SuiClientContext({ children }: React.PropsWithChildren) {
  const defaultNetwork = process.env.NODE_ENV !== "production" ? "testnet" : "mainnet";
  return (
    <SuiClientProvider networks={networkConfig} defaultNetwork={defaultNetwork}>
      <WalletProvider autoConnect>{children}</WalletProvider>
    </SuiClientProvider>
  );
}
