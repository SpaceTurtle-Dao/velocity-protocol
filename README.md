[![protocol.land](https://arweave.net/eZp8gOeR8Yl_cyH9jJToaCrt2He1PHr0pR4o-mHbEcY)](https://protocol.land/#/repository/<REPO_ID>)

# Velocity-Protocol - Messages and Operations Facilitated by Ao

The simplest open protocol capable of creating a censorship-resistant global "social" and operational network, designed to integrate seamlessly with Ao's decentralized messages.

It doesn’t rely on any trusted central server, ensuring resilience. It is based on cryptographic keys and signatures, making it tamper-proof. Unlike traditional P2P techniques, it is lightweight and efficient, optimized for the Ao environment.


## How it works

The idea is straightforward: every user can publish their messages and updates to multiple hubs (which act as decentralized nodes), and participants subscribing to these updates can connect to these hubs to retrieve the data. The protocol defines the communication between clients and hubs to publish and fetch relevant messages.

![](https://the-velocity.org/diagram.jpg)

These hubs, are simply processes running on Ao and can be hosted by anyone. The open nature of the protocol ensures that as long as a hub is willing to host data, users can share their messages and workflows, while subscribers can reliably access them.

Although hubs could potentially misrepresent data, cryptographic validation ensures trustworthiness. Public-key cryptography secures every message and update, with all content signed by the originator. When subscribing to a participant, you’re essentially following their public key. Clients will validate messages from hubs to ensure they are properly signed and authentic.

The primary challenge is discovering which hub contains the messages for a specific user or workflow. Various heuristics and algorithms, tailored to Ao’s distributed architecture, are actively being developed to address this. Contributors are encouraged to propose solutions to enhance message discovery and routing efficiency within the ecosystem.

## Protocol specification

Refer to the [VIPs (Velocity Improvement Proposals)](./vips/) and especially [VIP-01](./vips/01.md) for a detailed overview of the protocol’s specifications.

## Public Hub Process
`6gLP92yIF8ZgrHZpogUoFeyFuJl9utOaxyK58VFnpCM`

## License

Public domain.





