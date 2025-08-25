/// Package Name: voting_system
/// Module Name: dashboard
module voting_system::dashboard;

use sui::types;
use voting_system::debug;

const EDuplicateProposal: u64 = 0;
const EInvalidOtw: u64 = 1;

public struct Dashboard has key {
    id: UID,
    proposals_ids: vector<ID>,
}

public struct AdminCap has key {
    id: UID,
}

// hot potato pattern - struct with no abilities
// it can't be stored, copied or discarded
// OTW {@link https://move-book.com/programmability/one-time-witness}
public struct DASHBOARD has drop {}

fun init(otw: DASHBOARD, ctx: &mut TxContext) {
    debug::create_debug_obj(&otw);

    new(otw, ctx);

    // 소유권 할당 및 전환
    transfer::transfer(
        AdminCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    );
}

public fun new(otw: DASHBOARD, ctx: &mut TxContext) {
    assert!(types::is_one_time_witness(&otw), EInvalidOtw);

    let dashboard = Dashboard {
        id: object::new(ctx),
        proposals_ids: vector[],
    };

    // dashboard가 register_proposal fun의 self로 전달
    // dashboard.register_proposal(proposal_id);

    transfer::share_object(dashboard);
}

public fun register_proposal(self: &mut Dashboard, _admin_cap: &AdminCap, proposal_id: ID) {
    // `!`는 실행 결과가 false이면 에러를 반환 하고 함수종료
    assert!(!self.proposals_ids.contains(&proposal_id), EDuplicateProposal);

    self.proposals_ids.push_back(proposal_id);
}

public fun getProposalIds(self: &Dashboard): vector<ID> {
    self.proposals_ids
}

// transfer는 public 공개를 하면 안되지만 테스트에서는 예외적으로 함수를 허용 해줌.
// 테스트가 아닌 실제 함수로 할 경우 보안 이슈
#[test_only]
public fun issue_admin_cap(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(
        admin_cap,
        ctx.sender(),
    );
}

#[test_only]
public fun new_otw(_ctx: &mut TxContext): DASHBOARD {
    DASHBOARD {}
}

#[test]
fun test_module_init() {
    use sui::test_scenario;

    let creator = @0xCA;

    let mut scenario = test_scenario::begin(creator);
    {
        let otw = DASHBOARD {};
        init(otw, scenario.ctx());
        debug::create_debug_msg(b"test_module_init".to_string())
    };
    scenario.next_tx(creator);
    {
        let dashboard = scenario.take_shared<Dashboard>();
        assert!(dashboard.proposals_ids.is_empty());

        test_scenario::return_shared(dashboard);
    };

    scenario.end();
}
