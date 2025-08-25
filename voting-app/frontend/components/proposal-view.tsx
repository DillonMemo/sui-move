"use client";

import { getSuiObjectFields } from "@/lib/utils";
import { useNetworkVariable } from "@/providers/sui-client-context";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import ProposalItem from "./proposal/ProposalItem";
import EcText from "@/components/Shared";

export default function ProposalView() {
  const dashboardId = useNetworkVariable("dashboardId");

  const {
    data: dataResponse,
    isPending,
    error,
  } = useSuiClientQuery("getObject", {
    id: dashboardId,
    options: {
      showContent: true,
    },
  });
  if (isPending) return <EcText text={"Loading..."} centered />;
  if (error) return <EcText text={`Error: ${error.message}`} isError />;
  if (!dataResponse.data) return <EcText text={"Object Not Found..."} isError />;

  return (
    <>
      <h1 className="text-4xl md:text-xl font-bold">New Proposals</h1>
      <div className="mt-4 grid lg:grid-cols-3 sm:grid-cols-2 grid-cols-1 gap-4">
        {getSuiObjectFields<{ id: SuiID; proposals_ids: string[] }>(
          dataResponse.data
        )?.proposals_ids.map((id) => (
          <ProposalItem key={id} id={id} />
        ))}
      </div>
    </>
  );
}
