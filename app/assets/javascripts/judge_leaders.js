$(function() {
  $('ul.judge-leaders-category-list').addClass('tabs').attr(
    'data-responsive-tabs', 'accordion medium-tabs large-tabs').attr(
    'data-tabs', '');
  $('li.judge-leaders-category').addClass('tabs-title');
  $('li.judge-leaders-category:first').addClass('is-active');
  $('div.judge-leaders-category-collection').addClass('tabs-content').attr(
    'data-tabs-content', 'judge-leaders');
  $('div.judge-leaders-category').addClass('tabs-panel');
});
