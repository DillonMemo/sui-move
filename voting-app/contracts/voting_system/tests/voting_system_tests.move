#[test_only]
module voting_system::voting_system_tests;

use sui::clock;
use sui::test_scenario;
use voting_system::dashboard::{Self, AdminCap, Dashboard};
use voting_system::debug::{create_debug_obj, create_debug_msg};
use voting_system::proposal::{Self, Proposal, VoteProofNFT};

const EWrongVoteCount: u64 = 0;
const EWrongStatus: u64 = 1;

fun new_proposal(admin_cap: &AdminCap, ctx: &mut TxContext): ID {
    let title = b"제목입니다".to_string();
    let desc = b"설명입니다".to_string();

    proposal::create(
        admin_cap,
        title,
        desc,
        2000000000000,
        ctx,
    )
}

#[test]
fun test_create_proposal_with_admin_cap() {
    let user = @0xCA;

    let mut scenario = test_scenario::begin(user);
    {
        dashboard::issue_admin_cap(scenario.ctx())
    };

    scenario.next_tx(user);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        create_debug_msg(b"with admin cap".to_string());
        create_debug_obj(&admin_cap);

        new_proposal(&admin_cap, scenario.ctx());

        test_scenario::return_to_sender(&scenario, admin_cap)
    };
    scenario.next_tx(user);
    {
        let created_proposal = scenario.take_shared<Proposal>();
        create_debug_obj(&created_proposal);
        assert!(created_proposal.getTitle() == b"제목입니다".to_string());
        assert!(created_proposal.getDescription() == b"설명입니다".to_string());
        assert!(created_proposal.getExpiration() == 2000000000000); // 미래: 17587303175880642100066, // 과거 1756128021000
        assert!(created_proposal.getVotedYesCount() == 0);
        assert!(created_proposal.getVotedNoCount() == 0);
        assert!(created_proposal.getCreator() == user);
        assert!(created_proposal.getVoters().is_empty()); // == vector::is_empty(&created_proposal.getVoterRegistry())

        test_scenario::return_shared(created_proposal)
    };

    scenario.end();
}

#[test]
#[
    expected_failure(
        abort_code = test_scenario::EEmptyInventory,
    ),
] // 에러가 예상이 되고 예상되는 에러를 예외처리 할때.
fun test_create_proposal_no_admin_cap() {
    let user = @0xB0B;
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx())
    };

    scenario.next_tx(user);
    {
        create_debug_msg(b"no admin cap".to_string());
        let admin_cap = scenario.take_from_sender<AdminCap>(); // 여기서 admin 권한이 없어 에러 발생
        create_debug_obj(&admin_cap);

        new_proposal(&admin_cap, scenario.ctx());

        test_scenario::return_to_sender(&scenario, admin_cap)
    };

    scenario.end();
}

#[test]
fun test_register_proposal_as_admin() {
    let admin = @0xAD;
    let mut scenario = test_scenario::begin(admin);
    {
        let otw = dashboard::new_otw(scenario.ctx());
        dashboard::new(otw, scenario.ctx());
        dashboard::issue_admin_cap(scenario.ctx());
    };
    scenario.next_tx(admin);
    {
        let mut dashboard = scenario.take_shared<Dashboard>();
        let admin_cap = scenario.take_from_sender<AdminCap>();
        let proposal_id = new_proposal(&admin_cap, scenario.ctx());

        dashboard.register_proposal(&admin_cap, proposal_id);
        let proposal_ids = dashboard.getProposalIds();
        create_debug_msg(b"IDs".to_string());
        create_debug_obj(&proposal_ids);
        let proposal_exists = proposal_ids.contains(&proposal_id);
        create_debug_msg(b"Exists".to_string());
        create_debug_obj(&proposal_exists);
        assert!(proposal_exists);
        scenario.return_to_sender(admin_cap);
        test_scenario::return_shared(dashboard);
    };

    scenario.end();
}

#[test]
// #[expected_failure(abort_code = EEmptyInventory)]
fun test_voting() {
    let bob = @0xB0B;
    let alice = @0xA11CE;

    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx())
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>(); // 여기서 admin 권한이 없어 에러 발생
        create_debug_msg(b"=== Admin Cap ===".to_string());
        create_debug_obj(&admin_cap);

        new_proposal(&admin_cap, scenario.ctx());

        test_scenario::return_to_sender(&scenario, admin_cap)
    };

    // proposal 상태를 변경하는 테스트 트랜잭션
    // scenario.next_tx(admin);
    // {
    //     let admin_cap = scenario.take_from_sender<AdminCap>(); // 여기서 admin 권한이 없어 에러 발생
    //     let mut proposal = scenario.take_shared<Proposal>();
    //     proposal.test_set_delisted_status(&admin_cap);

    //     test_scenario::return_shared(proposal);
    //     test_scenario::return_to_sender(&scenario, admin_cap);
    // };

    scenario.next_tx(bob);
    {
        let mut proposal = scenario.take_shared<Proposal>();
        let mut test_clock = clock::create_for_testing(scenario.ctx());
        test_clock.set_for_testing(1990000000000);

        create_debug_msg(b"=== 1. proposal status ===".to_string());
        create_debug_obj(proposal.getStatus());

        // 첫투표
        let old_nft = option::none();
        proposal.vote(false, old_nft, &test_clock, scenario.ctx());

        create_debug_msg(b"=== 1. getVotedYesCount ===".to_string());
        create_debug_obj(&proposal.getVotedYesCount());
        create_debug_msg(b"=== 1. getVotedNoCount ===".to_string());
        create_debug_obj(&proposal.getVotedNoCount());

        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.next_tx(bob);
    {
        let mut proposal = scenario.take_shared<Proposal>();
        let mut test_clock = clock::create_for_testing(scenario.ctx());
        test_clock.set_for_testing(1990000000000);

        let bob_nft = scenario.take_from_sender<VoteProofNFT>();

        // 재투표 (false -> false, 같은 선택)
        let old_nft = option::some(bob_nft);
        proposal.vote(false, old_nft, &test_clock, scenario.ctx());

        create_debug_msg(b"=== 2. getVotedYesCount ===".to_string());
        create_debug_obj(&proposal.getVotedYesCount());
        create_debug_msg(b"=== 2. getVotedNoCount ===".to_string());
        create_debug_obj(&proposal.getVotedNoCount());

        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    // Bob의 두 번째 NFT 가져오기
    scenario.next_tx(bob);
    {
        let mut test_clock = clock::create_for_testing(scenario.ctx());
        test_clock.set_for_testing(1990000000000);
        let mut proposal = scenario.take_shared<Proposal>();
        let bob_nft2 = scenario.take_from_sender<VoteProofNFT>();
        create_debug_msg(b"=== 3. bob nfts ===".to_string());
        create_debug_obj(&bob_nft2);

        // 재투표 (false -> true, 다른 선택)
        let old_nft = option::some(bob_nft2);
        proposal.vote(true, old_nft, &test_clock, scenario.ctx());

        create_debug_msg(b"=== 3. getVotedYesCount ===".to_string());
        create_debug_obj(&proposal.getVotedYesCount());
        create_debug_msg(b"=== 3. getVotedNoCount ===".to_string());
        create_debug_obj(&proposal.getVotedNoCount());

        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.next_tx(alice);
    {
        let mut test_clock = clock::create_for_testing(scenario.ctx());
        test_clock.set_for_testing(1990000000000);
        let mut proposal = scenario.take_shared<Proposal>();

        // alice 첫투표
        let old_nft = option::none();
        proposal.vote(true, old_nft, &test_clock, scenario.ctx());

        create_debug_msg(b"=== 4. getVotedYesCount ===".to_string());
        create_debug_obj(&proposal.getVotedYesCount());
        create_debug_msg(b"=== 4. getVotedNoCount ===".to_string());
        create_debug_obj(&proposal.getVotedNoCount());
        assert!(proposal.getVotedYesCount() == 2, EWrongVoteCount);
        assert!(proposal.getVotedNoCount() == 0, EWrongVoteCount);

        // NFT 확인 후 다시 Bob에게 반환
        // test_scenario::return_to_address<VoteProofNFT>(bob, old_nft_2.destroy_some());
        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.end();
}

#[test]
fun test_change_proposal_status() {
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx())
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());

        test_scenario::return_to_sender(&scenario, admin_cap);
    };

    scenario.next_tx(admin);
    {
        let proposal = scenario.take_shared<Proposal>();
        assert!(proposal.is_active());
        test_scenario::return_shared(proposal)
    };

    scenario.next_tx(admin);
    {
        let mut proposal = scenario.take_shared<Proposal>();
        let admin_cap = scenario.take_from_sender<AdminCap>();
        proposal.test_set_delisted_status(&admin_cap);

        assert!(!proposal.is_active(), EWrongStatus);
        test_scenario::return_shared(proposal);
        scenario.return_to_sender(admin_cap);
    };

    scenario.end();
}
