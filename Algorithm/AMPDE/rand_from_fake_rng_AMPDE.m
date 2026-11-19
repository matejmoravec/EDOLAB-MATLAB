% --- rand(rows,cols) from FakeRng, filled row by row (same order as Kotlin) ---
function U = rand_from_fake_rng_AMPDE(fakeRng, rows, cols)
U = zeros(rows,cols);
for rr = 1:rows
    for cc = 1:cols
        U(rr,cc) = fakeRng.nextDouble(0,1);
    end
end
end
