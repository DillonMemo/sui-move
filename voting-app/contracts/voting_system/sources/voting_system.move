/// Package Name: voting_system
/// Module Name: dashboard
module voting_system::dashboard;

use std::string::String;

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

public fun create_proposal(
    title: String,
    description: String,
    expiration: u64,
    ctx: &mut TxContext,
): Proposal {
    let proposal = Proposal {
        id: object::new(ctx),
        title,
        description,
        voted_yes_count: 0,
        voted_no_count: 0,
        expiration,
        creator: ctx.sender(),
        voter_registry: vector[],
    };

    // transfer::share_object(proposal)
    proposal
}
