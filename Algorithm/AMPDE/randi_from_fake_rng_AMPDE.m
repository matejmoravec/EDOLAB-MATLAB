% --- randi([1,n]) from FakeRng: one draw, floor(u*n)+1 ---
function k = randi_from_fake_rng_AMPDE(fakeRng, n)
k = min(floor(fakeRng.nextDouble(0,1) * n) + 1, n);
end
