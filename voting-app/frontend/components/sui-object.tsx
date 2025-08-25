import { type SuiObjectResponse } from "@mysten/sui/client";

interface Props {
  objectRes: SuiObjectResponse;
}
export default function SuiObject({ objectRes }: Props) {
  const owner = objectRes.data?.owner;
  const objectType = objectRes.data?.type;

  const isCoin = objectType?.includes("0x2::coin::Coin");
  const balance =
    isCoin &&
    objectRes.data?.content?.dataType === "moveObject" &&
    "balance" in objectRes.data?.content.fields
      ? (objectRes.data?.content.fields.balance as number)
      : -1;
  return (
    <div className="p-2 border border-accent-foreground rounded-lg bg-gray-50 dark:bg-gray-800">
      <p className="text-gray-700 dark:text-gray-300">
        <strong>Object ID:</strong> {objectRes.data?.objectId}
      </p>
      <p className="text-gray-700 dark:text-gray-300">
        <strong>Type:</strong> {objectRes.data?.type}
      </p>
      <p className="text-gray-700 dark:text-gray-300">
        <strong>Owner:</strong>{" "}
        {typeof owner === "object" && owner !== null && "AddressOwner" in owner
          ? owner.AddressOwner
          : "Unknown"}
      </p>
      {isCoin && (
        <p className="text-gray-700 dark:text-gray-300">
          <strong>Balance:</strong> {balance}
        </p>
      )}
    </div>
  );
}
