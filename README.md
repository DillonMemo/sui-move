## Sui CLI Guide

```shell

sui client faucet # 수이 테스트 코인 요청

sui client addresses # 수이 지갑 목록 조회

sui client new-address ed25519 # 신규 지갑 생성
sui keytool import "{phase}" ed25519 # 기존 지갑 추가

sui client switch --address {alias-name} # active 주소 변경

```