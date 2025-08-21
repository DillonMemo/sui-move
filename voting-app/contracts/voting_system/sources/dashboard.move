/// Package Name: voting_system
/// Module Name: dashboard
module voting_system::dashboard;

use voting_system::debug::{create_debug_msg, create_debug_obj};

public struct Dashboard has key {
    id: UID,
    proposals_ids: vector<ID>,
}

public struct AdminCap has key {
    id: UID,
}

// hot potato pattern - struct with no abilities
// it can't be stored, copied or discarded
public struct Potato {}
public struct ShoppingCart {
    items: vector<u64>,
}

// Drop ability
public struct DashboardConfig has drop {
    value: u64,
}

// OTW {@link https://move-book.com/programmability/one-time-witness}
public struct DASHBOARD has drop {}

fun init(otw: DASHBOARD, ctx: &mut TxContext) {
    create_debug_obj(&otw);

    new(otw, ctx);

    // 소유권 할당 및 전환
    transfer::transfer(
        AdminCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    );
}

public fun new(_otw: DASHBOARD, ctx: &mut TxContext) {
    let dashboard = Dashboard {
        id: object::new(ctx),
        proposals_ids: vector[],
    };
    let config = DashboardConfig { value: 100 };
    let mut config_2 = config;
    config_2.value = 200;
    let config_3 = config_2;
    create_debug_obj(&config_3);
    let potato = Potato {};

    consume_config(config_3);
    pass_potato(potato);
    // dashboard가 register_proposal fun의 self로 전달
    // dashboard.register_proposal(proposal_id);

    transfer::share_object(dashboard);
}

public fun checkout(shopping_cart: ShoppingCart) {
    payment(shopping_cart)
}

fun payment(shopping_cart: ShoppingCart) {
    let ShoppingCart { items: _ } = shopping_cart;
}

fun pass_potato(potato: Potato) {
    let Potato {} = potato;
}

fun consume_config(_config: DashboardConfig) {}

public fun register_proposal(self: &mut Dashboard, proposal_id: ID) {
    self.proposals_ids.push_back(proposal_id)
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
#[test]
fun test_module_init() {
    use sui::test_scenario;

    let creator = @0xCA;

    let mut scenario = test_scenario::begin(creator);
    {
        let otw = DASHBOARD {};
        init(otw, scenario.ctx());
        create_debug_msg(b"test_module_init".to_string())
    };
    scenario.next_tx(creator);
    {
        let dashboard = scenario.take_shared<Dashboard>();
        assert!(dashboard.proposals_ids.is_empty());

        test_scenario::return_shared(dashboard);
    };

    scenario.end();
}
