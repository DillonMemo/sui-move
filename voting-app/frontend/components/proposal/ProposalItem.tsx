import { cn, getSuiObjectFields } from "@/lib/utils";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import EcText from "@/components/Shared";
import { Proposal } from "@/lib/types";
import VoteModal from "@/components/proposal/VoteModal";
import { useState } from "react";

type ProposalItemsProps = {
  id: string;
};

export default function ProposalItem({ id }: ProposalItemsProps) {
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const {
    data: response,
    isPending,
    error,
  } = useSuiClientQuery("getObject", {
    id,
    options: {
      showContent: true,
    },
  });

  if (isPending) return <EcText text={"Loading..."} centered />;
  if (error) return <EcText text={`Error: ${error.message}`} isError />;
  if (!response.data) return <EcText text={"Object Not Found..."} isError />;

  const proposal = getSuiObjectFields<Proposal>(response.data);
  if (!proposal) return <EcText text="No data found!" />;

  const expiration = proposal.expiration;
  const isExpired = new Date(Number(expiration) * 1000) < new Date();
  return (
    <>
      <div
        className={cn(
          "p-4 border rounded-lg shadow-sm transition-colors",
          "bg-zinc-200 dark:bg-zinc-800",
          "flex flex-col gap-2 break-words",
          isExpired ? "cursor-not-allowed border-gray-600" : "cursor-pointer hover:border-blue-500"
        )}
        {...(!isExpired && { onClick: () => setIsOpen(true) })}
      >
        <p className={cn(`text-xl font-semibold`, isExpired && "text-gray-500")}>
          {proposal.title}
        </p>
        <p className={cn(isExpired ? "text-gray-500" : "text-zinc-700 dark:text-zinc-300")}>
          {proposal.description}
        </p>
        <div className="flex items-center justify-between mt-2">
          <div className="flex space-x-4">
            <div
              className={cn("flex items-center", isExpired ? "text-green-800" : "text-green-600")}
            >
              <span className="mr-1">👍</span>
              {proposal.voted_yes_count}
            </div>
            <div className={cn("flex items-center", isExpired ? "text-red-800" : "text-red-600")}>
              <span className="mr-1">👎</span>
              {proposal.voted_no_count}
            </div>
          </div>
          <div className="text-sm">
            <p
              className={cn(
                isExpired ? "text-zinc-400 dark:text-zinc-700" : "text-zinc-700 dark:text-zinc-400"
              )}
            >
              {isExpired
                ? "Expired"
                : new Date(Number(expiration) * 1000).toLocaleDateString("en-US", {
                    month: "short",
                    day: "2-digit",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                    second: "2-digit",
                  })}
            </p>
          </div>
        </div>
      </div>
      <VoteModal
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        proposal={proposal}
        onVote={(votedYes: boolean) => console.log("votedYes", votedYes)}
      />
    </>
  );
}
