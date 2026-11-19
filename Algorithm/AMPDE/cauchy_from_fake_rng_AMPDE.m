% --- Cauchy sample (tLocationScale with nu = 1) from FakeRng: one draw, inverse CDF ---
function x = cauchy_from_fake_rng_AMPDE(fakeRng, mu, sigma)
x = mu + sigma * tan(pi * (fakeRng.nextDouble(0,1) - 0.5));
end
