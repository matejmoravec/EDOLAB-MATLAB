% --- local helper for Gaussian samples from uniform FakeRng ---
function z = randn_from_fake_rng(fakeRng)
u1 = max(fakeRng.nextDouble(0,1), realmin);
u2 = fakeRng.nextDouble(0,1);
z = sqrt(-2*log(u1)) * cos(2*pi*u2);
end