# CooldownAuthorizer Feature Overview

## Overview

The CooldownAuthorizer implements a time-based withdrawal mechanism for the LiteVault contract that requires users to wait for a specified cooldown period before completing their withdrawals. Key features include:

1. **Configurable Cooldown Periods**: Multiple cooldown duration options can be enabled/disabled by the contract owner, allowing for flexible withdrawal policies.

2. **User-selected Cooldown**: When requesting a withdrawal, users can select from supported cooldown periods, offering a balance between security and convenience.

3. **Immutable Requests**: Once a withdrawal is requested, it can not be affected by the cooldown period modification, ensuring predictable withdrawal timelines.

4. **Cooldown Enforcement**: The `authorize` function verifies that the cooldown period has elapsed before allowing a withdrawal to proceed.

5. **Graceful Administration**: Owner can add or remove supported cooldown periods without affecting existing withdrawal requests, as their originally selected cooldown period remains valid regardless of later changes.

The core workflow is:

- User calls `requestWithdrawalWithCooldown` with token, amount, and desired cooldown period
- System emits a `CooldownRequested` event and stores request details
- After the cooldown period elapses, a withdrawal from LiteVault will be authorized
- If attempted before cooldown expiry, the withdrawal is rejected

NOTE: Having implemented this, it is still not possible to disallow depositing while the cooldown is active.

## Integration plan

1. Separate the unlock and withdraw processes on FE
2. Change FE to support users specifying a cooldown period during withdrawal request
3. Make a transaction to CooldownAuthorizer on FE
4. Deploy CooldownAuthorizer contract on 8 currently supported chains
5. Set the LiteVault authorizer to the CooldownAuthorizer contract on the 8 chains

NOTE: possibly no changes to Pathfinder (BE) unless we want to store the cooldown period and/or withdrawal request info.

NOTE: if we want to add different logic to different cooldown periods, we NEED the Pathfinder to listen to withdrawal requests and update the logic as we need.

## Withdrawal request double-spending problem

### Problem Statement

We need a mechanism to outdate withdrawal requests after they have been fulfilled. However, the `authorize` function in the `IAuthorize` interface is `view` so it's not possible to update the state.

The vault is already deployed and we can't change it. We could have added some post-withdrawal call logic to the vault, but this is no longer an option.

The main reason why the withdrawal request needs to be invalidated is that a user may deposit more funds to the LiteVault during the cooldown period, and request 2 consecutive withdrawals.

The first one will succeed as designed, but the second one will also succeed because the withdrawal request is not invalidated and user can still withdraw this token.

A timeout approach would only work if the difference between the first withdrawal and the second is greater than this timeout, which we cannot assume.

### Possible Solutions

#### 1. User-initiated request refresh

- Add function for users to explicitly refresh/update withdrawal requests
- Requires user understanding of the extra step

#### 2. Request with specific identifiers

- Track multiple withdrawal requests with unique IDs
- Would require LiteVault modification (not possible)

#### 3. Time-bounded requests

- Add validity period to requests
- Requests expire after cooldown + short window
- Potential UX issues if window too short

#### 4. Interface modification

- Modify IAuthorize to have non-view authorize function
- Breaking change requiring new vault deployment

### Recommendation

The ideal solution would be creating a new IAuthorize2 interface with a non-view authorize function, then deploying a new version of LiteVault that uses this interface.

If that's not possible, the user-initiated request refresh mechanism (Option 1) provides the most practical solution within the current constraints, though it requires users to understand the extra withdrawal request step whenever they want to withdraw again after depositing more funds.
