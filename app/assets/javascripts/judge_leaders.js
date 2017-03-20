$(function() {
  $('ul.judge-leaders-category-list').addClass('accordion').attr(
    'data-responsive-accordion-tabs', 'accordion medium-tabs large-tabs').attr(
    'data-accordion', '').attr(
    'data-multi-expand','true').attr(
    'data-allow-all-closed', 'true');
  $('li.judge-leaders-category').addClass('accordion-item').attr(
    'data-accordion-item', '');
  $('li.judge-leaders-category:first').addClass('is-active');
  $('li.judge-leaders-category a').addClass('accordian-title');
  $('div.judge-leaders-category').addClass('accordion-content').attr(
    'data-tab-content', '');
});
