/// Package Name: voting_system
/// Module Name: dashboard
module voting_system::dashboard;

use voting_system::debug::create_debug_msg;

public struct Dashboard has key {
    id: UID,
    proposals_ids: vector<ID>,
}

public struct AdminCap has key {
    id: UID,
}

fun init(ctx: &mut TxContext) {
    new(ctx);

    // 소유권 할당 및 전환
    transfer::transfer(
        AdminCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    );
}

public fun new(ctx: &mut TxContext) {
    let dashboard = Dashboard {
        id: object::new(ctx),
        proposals_ids: vector[],
    };

    // dashboard가 register_proposal fun의 self로 전달
    // dashboard.register_proposal(proposal_id);

    transfer::share_object(dashboard);
}

public fun register_proposal(self: &mut Dashboard, proposal_id: ID) {
    self.proposals_ids.push_back(proposal_id)
}

// transfer는 public 공개를 하면 안되지만 테스트에서는 예외적으로 함수를 허용 해줌.
// 테스트가 아닌 실제 함수로 할 경우 보안 이슈
#[test_only]
public fun issue_admin_cap(ctx: &mut TxContext) {
    transfer::transfer(
        AdminCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    )
}
#[test]
fun test_module_init() {
    use sui::test_scenario;

    let creator = @0xCA;

    let mut scenario = test_scenario::begin(creator);
    {
        init(scenario.ctx());
        create_debug_msg(b"ONE".to_string())
    };
    scenario.next_tx(creator);
    {
        let dashboard = scenario.take_shared<Dashboard>();
        assert!(dashboard.proposals_ids.is_empty());

        test_scenario::return_shared(dashboard);
    };

    scenario.end();
}
