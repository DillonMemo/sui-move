import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import SuiObject from "./sui-object";

export default function OwnedObjects() {
    const account = useCurrentAccount();

    const {
        data: response,
        error,
        isPending,
    } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: account?.address as `0x${string}`,
            options: {
                showType: true,
                showOwner: true,
                showContent: true,
            },
        },
        {
            enabled: !!account,
        }
    );

    if (!account) return "Cannot retreive account";
    if (error) return <div className="text-red-500">Error: {error.message}</div>;

    if (isPending || !response) {
        return <div className="text-center text-gray-500">Loading...</div>;
    }

    return (
        <div className="flex flex-col gap-4 my-4">
            {response.data.length === 0 ? (
                <p className="text-gray-700 dark:text-gray-300">
                    No objects owned by connected wallet.
                </p>
            ) : (
                <h2 className="text-xl font-semibold text-gray-800 dark:text-gray-100">
                    Object owned by connected wallet:
                </h2>
            )}
            <div className="space-y-2">
                {response.data.map((objectRes, index) => (
                    <SuiObject key={objectRes.data?.objectId || index} objectRes={objectRes} />
                ))}
            </div>
        </div>
    );
}
