#[test_only]
module voting_system::voting_system_tests;

use sui::test_scenario;
use voting_system::dashboard::{Self, AdminCap};
use voting_system::debug::{create_debug_obj, create_debug_msg};
use voting_system::proposal::{Self, Proposal};

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
        assert!(created_proposal.getExpiration() == 2000000000);
        assert!(created_proposal.getVotedYesCount() == 0);
        assert!(created_proposal.getVotedNoCount() == 0);
        assert!(created_proposal.getCreator() == user);
        assert!(created_proposal.getVoterRegistry().is_empty()); // == vector::is_empty(&created_proposal.getVoterRegistry())

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

fun new_proposal(admin_cap: &AdminCap, ctx: &mut TxContext) {
    let title = b"제목입니다".to_string();
    let desc = b"설명입니다".to_string();

    proposal::create(
        admin_cap,
        title,
        desc,
        2000000000,
        ctx,
    );
}
