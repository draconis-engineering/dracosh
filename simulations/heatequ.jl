using Plots

@main function simulate()::Nothing
    # Physical and Numerical Parameters
    L = 1.0        # Length of the rod (meters)
    Nx = 50        # Number of spatial grid points
    dx = L / (Nx - 1)

    alpha = 0.01   # Thermal diffusivity coefficient
    t_max = 2.0    # Total simulation time (seconds)
    dt = 0.0001    # Time step (must be very small for stability!)
    Nt = Int(t_max / dt)

    # Check Stability Criterion: dt <= dx^2 / (2 * alpha)
    if dt > (dx^2) / (2 * alpha)
        error("Simulation unstable! Decrease dt or increase Nx.")
    end

    # Initialize Temperature Array (Initial Conditions)
    # Start with a cold rod (0°C) and a hot spot (100°C) in the middle
    T = zeros(Nx)
    mid = div(Nx, 2)
    T[mid-4:mid+4] .= 100.0

    # Time-Stepping Loop
    # Keep track of temperatures at specific intervals for animation
    history = [copy(T)]
    frame_interval = 200 # Save every 200th step to speed up plotting

    for t in 1:Nt
        T_new = copy(T)

        # Update interior points using the finite difference formula
        for i in 2:(Nx - 1)
            T_new[i] = T[i] + alpha * dt / dx^2 * (T[i+1] - 2*T[i] + T[i-1])
        end

        # Boundary Conditions (Ends of the rod stay cold at 0°C)
        T_new[1] = 0.0
        T_new[end] = 0.0

        T = T_new # Move to next time step

        if t % frame_interval == 0
            push!(history, copy(T))
        end
    end

    # Animate the Results
    println("Generating animation...")
    x = range(0, L, length=Nx)

    anim = @animate for (step, T_frame) in enumerate(history)
        plot(x, T_frame,
             ylims=(0, 100),
             xlims=(0, L),
             title="1D Heat Diffusion (Step $(step * frame_interval))",
             xlabel="Rod Position (m)",
             ylabel="Temperature (°C)",
             legend=false,
             linewidth=2,
             color=:red)
    end

    gif(anim, "heat_equation.gif", fps=15)
end

simulate()
