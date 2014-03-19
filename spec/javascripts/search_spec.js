describe('#sanitizeSearchValue', function() {
  it("doesn't change sanitized input", function() {
    expect(sanitizeSearchValue(["val 1", "val 2"])).toEqual(["val 1", "val 2"]);
  });

  it("creates an empty array in input is null", function() {
    expect(sanitizeSearchValue(null)).toEqual([""]);
  });
});