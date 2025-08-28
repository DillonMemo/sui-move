## Sui CLI Guide

```shell
# 수이(SUI)의 CLI버전이 서버와 다를경우 업그레이드 필요
brew upgrade sui # <-- homebrew 사용 유저의 경우

sui client faucet # 수이 테스트 코인 요청

sui client addresses # 수이 지갑 목록 조회

sui client new-address ed25519 # 신규 지갑 생성
sui keytool import "{phase}" ed25519 # 기존 지갑 추가

sui client switch --address {alias-name} # active 주소 변경

sui client publish --gas-budget 100000000 # 빌드한 컨트랙트를 온체인에 배포 (budget는 최대 가스한도이며 100000000 === 0.13SUI 인걸로 알고 있음.)

# 배포된 컨트렉트 실행방법 1
sui client call \
  --package {packageID} \
  --module {moduleName} \
  --function {funName} \
  --args "{args1}" "{args2}" {args3} \
  --gas-budget 100000000

# Programmable Transaction Block(PTB)
# 배포된 컨트렉트 실행방법 2 (트랜잭션 Call 여러번 가능)
# --split-coins는 가스비중 1000 gas를 따로 분리 하여 --assign {name}은 {name}이라는 이름으로 --transfer-objects에 등록된 {walletAddress}로 보낸다
sui client ptb \
  --move-call {packageID}::{moduleName}::{funName} \
  '"{args1}"' \
  '"{args2}"' \
  {args3} \
  --move-call {packageID}::{moduleName}::{funName} \
  '"{args1}"' \
  '"{args2}"' \
  {args3} \
  --split-coins gas "[1000]" \
  --assign coin \
  --transfer-objects "[coin]" @{walletAddress} \
  --gas-budget 10000000

# PTB 멀티콜 예제(example)
sui client ptb \
  --move-call 0x211f8a02e162ac659bde71ca16d5ebfee983984d14ce54f87cf1bbee08ead368::proposal::create \
  @0xa9668532d1ad052e164e875a88d34ae792520c302df263c07e33748dba814345 \
  '"Proposal 1"' '"Proposal Description 1"' 1758502149 \
  --assign proposal_id \
  --move-call 0x211f8a02e162ac659bde71ca16d5ebfee983984d14ce54f87cf1bbee08ead368::dashboard::register_proposal \
  @0x180b6670eb6b3de4cb429382cb7150d1a48bfb169ef23880caf268ab4aa3859d \
  @0xa9668532d1ad052e164e875a88d34ae792520c302df263c07e33748dba814345 \
  proposal_id \



  
  --move-call 0x211f8a02e162ac659bde71ca16d5ebfee983984d14ce54f87cf1bbee08ead368::proposal::create \
  @0xa9668532d1ad052e164e875a88d34ae792520c302df263c07e33748dba814345 \
  '"Proposal 2"' '"Proposal Description 2"' 1758502149 \
  --assign proposal_id \
  --move-call 0x211f8a02e162ac659bde71ca16d5ebfee983984d14ce54f87cf1bbee08ead368::dashboard::register_proposal \
  @0x180b6670eb6b3de4cb429382cb7150d1a48bfb169ef23880caf268ab4aa3859d \
  @0xa9668532d1ad052e164e875a88d34ae792520c302df263c07e33748dba814345 \
  proposal_id \
  --move-call 0x211f8a02e162ac659bde71ca16d5ebfee983984d14ce54f87cf1bbee08ead368::proposal::create \
  @0xa9668532d1ad052e164e875a88d34ae792520c302df263c07e33748dba814345 \
  '"Proposal 3"' '"Proposal Description 3"' 1758502149 \
  --assign proposal_id \
  --move-call 0x211f8a02e162ac659bde71ca16d5ebfee983984d14ce54f87cf1bbee08ead368::dashboard::register_proposal \
  @0x180b6670eb6b3de4cb429382cb7150d1a48bfb169ef23880caf268ab4aa3859d \
  @0xa9668532d1ad052e164e875a88d34ae792520c302df263c07e33748dba814345 \
  proposal_id 

```

# Sui with WebApp

┌─────────────────────────────┐
│        Browser              │
│ ┌─────────────┐     ┌─────┐ │
│ │  Web App    │◀───▶︎│Suiet│ │
│ └─────────────┘     └─────┘ │
└─────────────────────────────┘
              │
              │ (tx)
              ▼
      ┌─────────────────┐
      │   Sui Chain     │
      │  (Contract)     │
      └─────────────────┘