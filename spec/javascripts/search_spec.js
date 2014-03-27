describe('#sanitizeSearchValue', function() {
  it("doesn't change sanitized input", function() {
    expect(sanitizeSearchValue(["val 1", "val 2"])).toEqual(["val 1", "val 2"]);
  });

  it("creates an empty array in input is null", function() {
    expect(sanitizeSearchValue(null)).toEqual([""]);
  });
});


xdescribe('#createSearchCriteriaJSON', function() {
  beforeEach(function () {
    jasmine.getFixtures().fixturesPath = '/spec/javascripts/fixtures';
    $('#fixture').remove();
    $.ajax({
      async: false, // must be synchronous to guarantee that no tests are run before fixture is loaded
      dataType: 'html',
      url: 'search.html',
      success: function(data) {
        $('body').append($(data));
      }
    });
  });

  it("will create a JSON object", function() {
    // jasmine.getFixtures().load('search.html');
    //expect($('#metric_filter').find(":selected").text()).toEqual('Pull Requests');
    //expect($("select#metric_filter option:selected").text()).toEqual('Pull Requests');
    expect(jasmine.getFixtures()).toEqual('Jason');
  });
});