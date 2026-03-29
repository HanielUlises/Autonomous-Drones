# Autonomous Square Flight

A finite-state machine that commands an unmanned aerial vehicle to autonomously take off, fly a square pattern, and lands

---

![](backyard_flyer.gif)

---

## Concept

Reactive autonomy: the drone does not plan ahead in time. Instead, it reacts to its current sensed state and transitions into the next appropriate behavior. This is a classic **event-driven architecture** applied to physical flight control.

The drone's behavior is fully described by a **Finite State Machine (FSM)** 

```math
\delta : S \times E \rightarrow S
```

Where $S$ is the set of states, $E$ is the set of trigger events, and $\delta$ is the transition function. At any moment, the drone's next action is entirely determined by its current state and the incoming sensor event.

---

## The State Machine

The drone cycles through six discrete states:


MANUAL → ARMING → TAKEOFF → WAYPOINT → LANDING → DISARMING → MANUAL

Each transition is **guarded by a physical condition** — altitude threshold, proximity to waypoint, velocity magnitude, or arming status. No transition fires until its guard condition is satisfied, making the system robust against timing noise.

---

## The Square Trajectory

The flight path is a closed square in the local North-East frame, defined by four waypoints at a fixed altitude $h$:

```math
\mathbf{W} = \{(0, 0, h),\ (10, 0, h),\ (10, 10, h),\ (0, 10, h)\}
```

Each leg of the square has a length of **10 meters**. The total path length is:

```math
L = 4 \times 10 = 40 \text{ m}
```

The drone advances to the next waypoint when its Euclidean distance to the target drops below a threshold $\epsilon$:

```math
\|\mathbf{p}_{current}[0:2] - \mathbf{p}_{target}[0:2]\|_2 < \epsilon
```

This threshold-based proximity check prevents the drone from stalling indefinitely near a waypoint in the presence of wind or sensor noise.

---

## Coordinate Frame

All positions are expressed in the **local NED frame** (North-East-Down), which is standard for aerial vehicles. Because the Down axis points toward the ground, altitude is represented as a **negative** Z value:

```math
z_{NED} = -\text{altitude}
```

So a target altitude of 3 meters corresponds to $z = -3$ in the local frame. The system converts this when checking takeoff completion:

```math
\text{altitude} = -z_{NED} > 0.95 \times h_{target}
```

The 95% threshold provides a soft guard against overshoot oscillation triggering a premature waypoint command.

---

## Landing Condition

The drone transitions to disarming only when two conditions hold simultaneously near-zero altitude **and** near-zero vertical velocity:

```math
|z_{local}| < \delta_z \quad \text{and} \quad z_{local} - z_{home} < \delta_{home}
```

This dual condition prevents a false disarm trigger when the drone is merely passing through low altitude during a descent, ensuring it has truly settled on the ground.

---

## Communication Architecture

The drone communicates with the flight controller over **MAVLink** — a lightweight, header-only binary protocol designed for low-latency telemetry on embedded systems. The connection is established via TCP, and the FSM is driven entirely by asynchronous callbacks registered to incoming message IDs. There is no polling loop; the system is purely **interrupt-driven**.