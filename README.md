[![protocol.land](https://arweave.net/eZp8gOeR8Yl_cyH9jJToaCrt2He1PHr0pR4o-mHbEcY)](https://protocol.land/#/repository/<REPO_ID>)

# Velocity-Protocol - Messages and Operations Facilitated by AO

The simplest open protocol capable of creating a censorship-resistant global "social" and operational network, designed to integrate seamlessly with AO's decentralized messages.

It doesn't rely on any trusted central server, ensuring resilience. It is based on cryptographic keys and signatures, making it tamper-proof. Unlike traditional P2P techniques, it is lightweight and efficient, optimized for the AO environment.

## How it works

The idea is straightforward: every user can publish their messages and updates to multiple hubs (which act as decentralized nodes), and participants subscribing to these updates can connect to these hubs to retrieve the data. The protocol defines the communication between clients and hubs to publish and fetch relevant messages.

![](https://the-velocity.org/diagram.jpg)

These hubs are simply processes running on AO and can be hosted by anyone. The open nature of the protocol ensures that as long as a hub is willing to host data, users can share their messages and workflows, while subscribers can reliably access them.

Although hubs could potentially misrepresent data, cryptographic validation ensures trustworthiness. Public-key cryptography secures every message and update, with all content signed by the originator. When subscribing to a participant, you're essentially following their public key. Clients will validate messages from hubs to ensure they are properly signed and authentic.

Hub discovery is solved through the [Zones Registry](https://github.com/SpaceTurtle-Dao/Zones), a decentralized directory in the AO ecosystem. Hubs self-register in the registry, and clients can discover them by querying for zones of type "hub". This provides a robust, decentralized solution for finding available hubs without relying on central authorities.

## Protocol Specification

The Velocity Protocol is defined through VIPs (Velocity Improvement Proposals):

### Core Specifications  
- **[VIP-01](./vips/01.md)** - Basic protocol flow, message validation, and hub communication
- **[VIP-02](./vips/02.md)** - Follow lists and social graph management
- **[VIP-03](./vips/03.md)** - Text messages, replies, and threading
- **[VIP-04](./vips/04.md)** - Reactions and social interactions
- **[VIP-05](./vips/05.md)** - Media attachments and content handling

### AO-Specific Features
- **[VIP-06](./vips/06.md)** - Hub discovery via Zones Registry
- **[VIP-07](./vips/07.md)** - Security model and best practices

## Quick Start

### For Developers
1. Review [VIP-01](./vips/01.md) for basic protocol understanding
2. Implement ANS-104 message signing for AO processes
3. Connect to hub processes and start sending/receiving messages
4. Follow security guidelines in [VIP-07](./vips/07.md)

### For Hub Developers
1. Study process requirements in [VIP-06](./vips/06.md)
2. Implement `FetchEvents` and `Event` handlers in your AO process
3. Register your hub in the [Zones Registry](https://github.com/SpaceTurtle-Dao/Zones) with proper metadata
4. Follow security best practices from [VIP-07](./vips/07.md)

## Public Hub Process
**Process ID:** `g_eSbkmD4LzfZtXaCLmeMcLIBQrqxnY-oFQJJNMIn4w`

This is a reference implementation hub running on AO. Developers can use this hub for testing and development purposes.

## License

Public domain.