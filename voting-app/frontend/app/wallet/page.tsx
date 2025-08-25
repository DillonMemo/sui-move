import WalletView from "@/components/wallet-view";

export default function Wallet() {
  return (
    <div className="min-h-screen flex justify-center items-center bg-background">
      <main className="flex flex-col gap-[32px] row-start-2 justify-center items-center">
        <div className="max-w-screen-xl m-auto">
          <WalletView />
        </div>
      </main>
    </div>
  );
}
