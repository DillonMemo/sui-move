import { useCurrentAccount } from "@mysten/dapp-kit";
import OwnedObjects from "../owned-objects";
export default function WalletStatus() {
  const account = useCurrentAccount();

  return (
    <div className="my-2 p-4 border rounded-lg bg-zinc-100 dark:bg-zinc-800">
      <h2 className="mb-2 text-xl font-bold">Wallet Status</h2>
      {account ? (
        <div className="flex flex-col gap-1 text-gray-700 dark:text-gray-300">
          <p>Wallet connected</p>
          <p>
            Address: <span className="font-mono">{account.address}</span>
          </p>
        </div>
      ) : (
        <p className="text-gray-700 dark:text-gray-300">Wallet not connected</p>
      )}

      <OwnedObjects />
    </div>
  );
}
