export type Proposal = {
  id: SuiID;
  title: string;
  description: string;
  voted_yes_count: string;
  voted_no_count: string;
  expiration: string;
  creator: string;
  voters: { [address: string]: boolean }[];
};
