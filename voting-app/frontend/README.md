## Sui CLI Guide

```shell

sui client faucet # 수이 테스트 코인 요청

sui client addresses # 수이 지갑 목록 조회

sui client new-address ed25519 # 신규 지갑 생성
sui keytool import "{phase}" ed25519 # 기존 지갑 추가

sui client switch --address {alias-name} # active 주소 변경

sui client publish --gas-budget 100000000 # 빌드한 컨트랙트를 온체인에 배포 (budget는 최대 가스한도이며 100000000 === 0.13SUI 인걸로 알고 있음.)

```