/// Package Name: voting_system
/// Module Name: proposal
module voting_system::proposal;

use std::string::String;
use voting_system::dashboard::AdminCap;

public struct Proposal has key {
    id: UID,
    title: String,
    description: String,
    voted_yes_count: u64,
    voted_no_count: u64,
    expiration: u64,
    creator: address,
    /// vector > 배열과같은 타입
    voter_registry: vector<address>,
}

public fun create(
    _admin_cap: &AdminCap,
    title: String,
    description: String,
    expiration: u64,
    ctx: &mut TxContext,
) {
    let proposal = Proposal {
        id: object::new(ctx),
        title,
        description,
        voted_yes_count: 0,
        voted_no_count: 0,
        expiration,
        creator: ctx.sender(),
        voter_registry: vector::empty<address>(),
    };

    transfer::share_object(proposal);
}

public fun getTitle(self: &Proposal): String {
    self.title
}

public fun getDescription(self: &Proposal): String {
    self.description
}

public fun getVotedYesCount(self: &Proposal): u64 {
    self.voted_yes_count
}

public fun getVotedNoCount(self: &Proposal): u64 {
    self.voted_no_count
}

public fun getExpiration(self: &Proposal): u64 {
    self.expiration
}

public fun getCreator(self: &Proposal): address {
    self.creator
}

public fun getVoterRegistry(self: &Proposal): vector<address> {
    self.voter_registry
}
