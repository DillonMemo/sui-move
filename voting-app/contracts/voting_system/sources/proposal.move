/// Package Name: voting_system
/// Module Name: proposal
module voting_system::proposal;

use std::string::String;
use sui::table::{Self, Table};
use voting_system::dashboard::AdminCap;
use voting_system::debug::create_debug_msg;

public struct Proposal has key {
    id: UID,
    title: String,
    description: String,
    voted_yes_count: u64,
    voted_no_count: u64,
    expiration: u64,
    creator: address,
    /// ex Table Object
    /// { 0x01 : true }
    /// { 0x02 : false }
    /// { 0x03 : true }
    voters: Table<address, bool>,
    voter_addresses: vector<address>,
}

// === Public Functions ===
public fun vote(self: &mut Proposal, vote_yes: bool, ctx: &TxContext) {
    let sender = ctx.sender();

    // 기존 투표가 있다면 해당 카운트를 먼저 차감
    if (self.voters.contains(sender)) {
        let previous_vote = self.voters.remove(sender);

        // voter_addresses에서 sender 제거
        let (found, index) = self.voter_addresses.index_of(&sender);
        create_debug_msg(b"=== previous vote ===".to_string());
        if (found) {
            create_debug_msg(b"find address true".to_string());
            self.voter_addresses.remove(index);
        } else {
            create_debug_msg(b"find address false".to_string());
        };

        if (previous_vote) {
            create_debug_msg(b"previous vote > true".to_string());
            self.voted_yes_count = self.voted_yes_count - 1;
        } else {
            create_debug_msg(b"previous vote > false".to_string());
            self.voted_no_count = self.voted_no_count - 1;
        };
    };

    // 새로운 투표 카운트 증가
    if (vote_yes) {
        create_debug_msg(b"final vote > true".to_string());
        self.voted_yes_count = self.voted_yes_count + 1;
    } else {
        create_debug_msg(b"final vote > false".to_string());
        self.voted_no_count = self.voted_no_count + 1;
    };

    // 새로운 투표 추가
    self.voters.add(sender, vote_yes);
    self.voter_addresses.push_back(sender);
}

// === View Functions ===
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

public fun getVoters(self: &Proposal): &Table<address, bool> {
    &self.voters
}

public fun getVoterAddresses(self: &Proposal): &vector<address> {
    &self.voter_addresses
}

// === Admin Functions ===
public fun create(
    _admin_cap: &AdminCap,
    title: String,
    description: String,
    expiration: u64,
    ctx: &mut TxContext,
): ID {
    let proposal = Proposal {
        id: object::new(ctx),
        title,
        description,
        voted_yes_count: 0,
        voted_no_count: 0,
        expiration,
        creator: ctx.sender(),
        voters: table::new(ctx),
        voter_addresses: vector::empty<address>(),
    };
    // let id = object::uid_to_inner(&proposal.id);
    let id = proposal.id.to_inner();
    transfer::share_object(proposal);

    id
}
