import 'dart:convert';

import 'package:arcane_lexicon/src/config/site_config.dart';

/// SVG icons used in JavaScript for dynamic DOM manipulation.
class KBIcons {
  /// Copy icon (Lucide copy)
  static const String copy = '''
<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"></rect><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"></path></svg>''';

  /// Check icon for copied state (Lucide check)
  static const String check = '''
<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"></path></svg>''';
}

/// Configuration constants for scripts.
class KBScriptConfig {
  static const int maxSearchResults = 10;
  static const int minSearchQueryLength = 2;
  static const int copyFeedbackTimeout = 2000;
  static const String defaultThemeMode = 'dark';
}

/// Generates client-side JavaScript for the knowledge base.
class KBScripts {
  final String basePath;
  final List<KBStylesheetOption> stylesheetOptions;
  final String defaultStylesheetId;
  final bool paletteSwitcherEnabled;

  const KBScripts({
    this.basePath = '',
    this.stylesheetOptions = const <KBStylesheetOption>[],
    this.defaultStylesheetId = '',
    this.paletteSwitcherEnabled = false,
  });

  /// Generate the complete knowledge base scripts.
  String generate() {
    return '''
(function() {
  function initializeKnowledgeBaseGlobalScripts() {
    if (window.__kbGlobalInitialized) return;
    window.__kbGlobalInitialized = true;
    ${_themeUtilities()}
    ${_stylesheetUtilities()}
    ${_themeToggleHandler()}
    ${_stylesheetToggleHandler()}
    ${_searchFunctionality()}
    ${_sidebarCollapse()}
    ${_softNavigation()}
  }

  function initializeKnowledgeBasePageScripts() {
    ${_codeBlockCopyButtons()}
    ${_syntaxHighlighting()}
    ${_mediaEmbeds()}
    ${_tocScrollTracking()}
    ${_backToTop()}
    ${_topBarAutoHide()}
    ${_ratingFunctionality()}
  }

  window.__kbInitializePage = initializeKnowledgeBasePageScripts;
  window.__kbInitializeAll = function() {
    initializeKnowledgeBaseGlobalScripts();
    initializeKnowledgeBasePageScripts();
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', window.__kbInitializeAll);
  } else {
    window.__kbInitializeAll();
  }
})();
''';
  }

  /// Generate theme initialization script (runs before body).
  String generateThemeInit() {
    String stylesheetJson = _stylesheetOptionsJson();
    String fallbackStylesheetId = _fallbackStylesheetId();
    return '''
(function() {
  var mode = localStorage.getItem('arcane-theme-mode') || '${KBScriptConfig.defaultThemeMode}';
  var stylesheetOptions = $stylesheetJson;
  var stylesheetId = localStorage.getItem('arcane-stylesheet-id') || '$fallbackStylesheetId';
  if (stylesheetOptions.length && !stylesheetOptions.some(function(option) { return option.id === stylesheetId; })) {
    stylesheetId = '$fallbackStylesheetId';
  }

  function activeStylesheet() {
    for (var i = 0; i < stylesheetOptions.length; i++) {
      if (stylesheetOptions[i].id === stylesheetId) return stylesheetOptions[i];
    }
    return stylesheetOptions[0] || null;
  }

  function defaultPaletteFor(option) {
    if (!option || !option.palettes || !option.palettes.length) return '';
    var primary = option.defaultPaletteId;
    for (var i = 0; i < option.palettes.length; i++) {
      if (option.palettes[i].id === primary) return primary;
    }
    return option.palettes[0].id;
  }

  function paletteStorageKey(stylesheetId) {
    return 'arcane-palette-id-' + stylesheetId;
  }

  function resolvePaletteId(option) {
    if (!option) return '';
    var stored = localStorage.getItem(paletteStorageKey(option.id));
    if (stored) {
      for (var i = 0; i < (option.palettes || []).length; i++) {
        if (option.palettes[i].id === stored) return stored;
      }
    }
    return defaultPaletteFor(option);
  }

  var paletteId = resolvePaletteId(activeStylesheet());
  window.arcaneThemeMode = mode;
  window.arcaneStylesheetId = stylesheetId;
  window.arcanePaletteId = paletteId;
  document.documentElement.classList.remove('dark', 'light');
  document.documentElement.classList.add(mode === 'dark' ? 'dark' : 'light');

  function applyStylesheetMedia() {
    if (!stylesheetOptions.length) return;
    stylesheetOptions.forEach(function(option) {
      (option.palettes || []).forEach(function(palette) {
        var themeTag = document.getElementById(
          'arcane-theme-vars-' + option.id + '-' + palette.id,
        );
        var componentTag = document.getElementById(
          'arcane-component-styles-' + option.id + '-' + palette.id,
        );
        var media =
          option.id === stylesheetId && palette.id === paletteId
            ? 'all'
            : 'not all';
        if (themeTag) themeTag.media = media;
        if (componentTag) componentTag.media = media;
      });
    });
  }

  function applyRootTheme() {
    var root = document.getElementById('arcane-root');
    if (!root) return false;
    root.classList.remove('dark', 'light');
    root.classList.add(mode === 'dark' ? 'dark' : 'light');
    stylesheetOptions.forEach(function(option) {
      root.classList.remove('arcane-theme-' + option.id);
      root.classList.remove('kb-style-' + option.id);
      if (option.bodyClass) root.classList.remove(option.bodyClass);
      (option.palettes || []).forEach(function(palette) {
        root.classList.remove('kb-palette-' + palette.id);
        if (palette.bodyClass) root.classList.remove(palette.bodyClass);
      });
    });
    var current = activeStylesheet();
    if (current) {
      root.classList.add('arcane-theme-' + current.id);
      root.setAttribute('data-arcane-theme', current.id);
      root.classList.add('kb-style-' + current.id);
      if (current.bodyClass) root.classList.add(current.bodyClass);
      var palettes = current.palettes || [];
      for (var i = 0; i < palettes.length; i++) {
        if (palettes[i].id === paletteId) {
          root.setAttribute('data-arcane-palette', palettes[i].id);
          root.classList.add('kb-palette-' + palettes[i].id);
          if (palettes[i].bodyClass) root.classList.add(palettes[i].bodyClass);
          break;
        }
      }
    }
    return true;
  }

  function applyStyleSlots() {
    var slots = document.querySelectorAll('[data-kb-style-slot]');
    if (!slots.length) return false;
    slots.forEach(function(slot) {
      var isActive = slot.getAttribute('data-kb-style-slot') === stylesheetId;
      slot.hidden = !isActive;
      slot.classList.toggle('kb-style-slot-active', isActive);
      slot.setAttribute('aria-hidden', isActive ? 'false' : 'true');
      if (isActive) {
        slot.removeAttribute('inert');
      } else {
        slot.setAttribute('inert', '');
      }
    });
    return true;
  }

  applyStylesheetMedia();
  var appliedRoot = applyRootTheme();
  var appliedSlots = applyStyleSlots();
  if ((!appliedRoot || !appliedSlots) && typeof MutationObserver !== 'undefined') {
    var observer = new MutationObserver(function() {
      var nextRoot = applyRootTheme();
      var nextSlots = applyStyleSlots();
      if (nextRoot && nextSlots) {
        observer.disconnect();
      }
    });
    observer.observe(document.documentElement, { childList: true, subtree: true });
  }
})();
''';
  }

  static String _themeUtilities() =>
      '''
// ===== THEME UTILITIES =====
function getCurrentMode() {
  return localStorage.getItem('arcane-theme-mode') || '${KBScriptConfig.defaultThemeMode}';
}
function updateClasses() {
  var mode = getCurrentMode();
  var isDark = mode === 'dark';
  // Update html element for CSS variables to reach document scrollbar
  document.documentElement.classList.remove('dark', 'light');
  document.documentElement.classList.add(isDark ? 'dark' : 'light');
  // Update arcane-root for component styling
  var root = document.getElementById('arcane-root');
  if (root) {
    root.classList.remove('dark', 'light');
    root.classList.add(isDark ? 'dark' : 'light');
  }
}
function setMode(mode) {
  localStorage.setItem('arcane-theme-mode', mode);
  updateClasses();
  updateModeToggleIcon(mode);
  if (typeof notifyStylesheetChanged === 'function') {
    notifyStylesheetChanged();
  }
}
function updateModeToggleIcon(mode) {
  document.querySelectorAll('[data-kb-theme-toggle], #theme-toggle').forEach(function(themeToggle) {
    var lightIcon = themeToggle.querySelector('.theme-icon-light');
    var darkIcon = themeToggle.querySelector('.theme-icon-dark');
    if (lightIcon && darkIcon) {
      lightIcon.style.display = mode === 'dark' ? 'block' : 'none';
      darkIcon.style.display = mode === 'dark' ? 'none' : 'block';
    }
  });
}
updateClasses();
updateModeToggleIcon(getCurrentMode());
''';

  String _stylesheetUtilities() {
    String stylesheetJson = _stylesheetOptionsJson();
    String fallbackStylesheetId = _fallbackStylesheetId();
    return '''
function getCurrentStylesheetId() {
  var id = localStorage.getItem('arcane-stylesheet-id') || '$fallbackStylesheetId';
  var options = getStylesheetOptions();
  if (!options.length) return id;
  var valid = options.some(function(option) { return option.id === id; });
  return valid ? id : '$fallbackStylesheetId';
}
function getStylesheetOptions() {
  return $stylesheetJson;
}
function getStylesheetOption(id) {
  var options = getStylesheetOptions();
  for (var i = 0; i < options.length; i++) {
    if (options[i].id === id) return options[i];
  }
  return null;
}
function getActiveKbSlot() {
  return document.querySelector('[data-kb-style-slot].kb-style-slot-active') ||
    document.querySelector('[data-kb-style-slot]:not([hidden])') ||
    document.getElementById('arcane-root') ||
    document;
}
function getPaletteStorageKey(stylesheetId) {
  return 'arcane-palette-id-' + stylesheetId;
}
function getDefaultPaletteId(option) {
  if (!option || !option.palettes || !option.palettes.length) return '';
  var primary = option.defaultPaletteId;
  for (var i = 0; i < option.palettes.length; i++) {
    if (option.palettes[i].id === primary) return primary;
  }
  return option.palettes[0].id;
}
function getCurrentPaletteId(stylesheetId) {
  var option = getStylesheetOption(stylesheetId);
  if (!option) return '';
  var stored = localStorage.getItem(getPaletteStorageKey(option.id));
  if (stored) {
    for (var i = 0; i < (option.palettes || []).length; i++) {
      if (option.palettes[i].id === stored) return stored;
    }
  }
  return getDefaultPaletteId(option);
}
function updateStylesheetClasses() {
  var options = getStylesheetOptions();
  if (!options.length) return;
  var stylesheetId = getCurrentStylesheetId();
  var paletteId = getCurrentPaletteId(stylesheetId);
  var root = document.getElementById('arcane-root');
  options.forEach(function(option) {
    if (root) {
      root.classList.remove('arcane-theme-' + option.id);
      root.classList.remove('kb-style-' + option.id);
      if (option.bodyClass) root.classList.remove(option.bodyClass);
    }
    (option.palettes || []).forEach(function(palette) {
      var themeTag = document.getElementById(
        'arcane-theme-vars-' + option.id + '-' + palette.id,
      );
      var componentTag = document.getElementById(
        'arcane-component-styles-' + option.id + '-' + palette.id,
      );
      var media =
        option.id === stylesheetId && palette.id === paletteId
          ? 'all'
          : 'not all';
      if (themeTag) themeTag.media = media;
      if (componentTag) componentTag.media = media;
      if (root) {
        root.classList.remove('kb-palette-' + palette.id);
        if (palette.bodyClass) root.classList.remove(palette.bodyClass);
      }
    });
  });
  if (root) {
    var current = getStylesheetOption(stylesheetId);
    if (current) {
      root.classList.add('arcane-theme-' + current.id);
      root.setAttribute('data-arcane-theme', current.id);
      root.classList.add('kb-style-' + current.id);
      if (current.bodyClass) root.classList.add(current.bodyClass);
      var palettes = current.palettes || [];
      for (var i = 0; i < palettes.length; i++) {
        if (palettes[i].id === paletteId) {
          root.setAttribute('data-arcane-palette', palettes[i].id);
          root.classList.add('kb-palette-' + palettes[i].id);
          if (palettes[i].bodyClass) root.classList.add(palettes[i].bodyClass);
          break;
        }
      }
    }
  }
  document.querySelectorAll('[data-kb-style-slot]').forEach(function(slot) {
    var isActive = slot.getAttribute('data-kb-style-slot') === stylesheetId;
    slot.hidden = !isActive;
    slot.classList.toggle('kb-style-slot-active', isActive);
    slot.setAttribute('aria-hidden', isActive ? 'false' : 'true');
    if (isActive) {
      slot.removeAttribute('inert');
    } else {
      slot.setAttribute('inert', '');
    }
  });
}
function updateStylesheetSelect(id) {
  document.querySelectorAll('[data-kb-stylesheet-select]').forEach(function(select) {
    select.value = id;
  });
}
function updatePaletteSelect(stylesheetId, paletteId) {
  document.querySelectorAll('[data-kb-palette-select]').forEach(function(select) {
    var option = getStylesheetOption(stylesheetId);
    var palettes = option ? option.palettes || [] : [];
    while (select.firstChild) {
      select.removeChild(select.firstChild);
    }
    if (!palettes.length) {
      select.style.display = 'none';
      return;
    }
    select.style.display = '';
    palettes.forEach(function(palette) {
      var opt = document.createElement('option');
      opt.value = palette.id;
      opt.textContent = palette.label;
      if (palette.id === paletteId) opt.selected = true;
      select.appendChild(opt);
    });
  });
}
function notifyStylesheetChanged() {
  if (typeof CustomEvent === 'function') {
    window.dispatchEvent(new CustomEvent('arcane-style-change', {
      detail: {
        stylesheetId: getCurrentStylesheetId(),
        paletteId: getCurrentPaletteId(getCurrentStylesheetId()),
        mode: getCurrentMode()
      }
    }));
    return;
  }
  window.dispatchEvent(new Event('arcane-style-change'));
}
function setStylesheetId(id) {
  localStorage.setItem('arcane-stylesheet-id', id);
  window.arcaneStylesheetId = id;
  var paletteId = getCurrentPaletteId(id);
  window.arcanePaletteId = paletteId;
  updateStylesheetClasses();
  updateStylesheetSelect(id);
  updatePaletteSelect(id, paletteId);
  notifyStylesheetChanged();
}
function setPaletteId(stylesheetId, paletteId) {
  if (!paletteId) return;
  localStorage.setItem(getPaletteStorageKey(stylesheetId), paletteId);
  window.arcanePaletteId = paletteId;
  updateStylesheetClasses();
  updatePaletteSelect(stylesheetId, paletteId);
  notifyStylesheetChanged();
}
updateStylesheetClasses();
updateStylesheetSelect(getCurrentStylesheetId());
updatePaletteSelect(getCurrentStylesheetId(), getCurrentPaletteId(getCurrentStylesheetId()));
''';
  }

  static String _themeToggleHandler() => '''
// ===== THEME TOGGLE =====
document.addEventListener('click', function(e) {
  var target = e.target;
  if (!target || !target.closest) return;
  var themeToggle = target.closest('[data-kb-theme-toggle], #theme-toggle');
  if (!themeToggle) return;
  e.preventDefault();
  var currentMode = getCurrentMode();
  var newMode = currentMode === 'dark' ? 'light' : 'dark';
  setMode(newMode);
});
''';

  String _stylesheetToggleHandler() => '''
document.addEventListener('change', function(e) {
  var target = e.target;
  if (!target || !target.matches) return;
  if (target.matches('[data-kb-stylesheet-select]')) {
    setStylesheetId(target.value);
    return;
  }
  if (target.matches('[data-kb-palette-select]')) {
    setPaletteId(getCurrentStylesheetId(), target.value);
  }
});
''';

  String _stylesheetOptionsJson() {
    List<Map<String, Object>> options = stylesheetOptions.map((
      KBStylesheetOption option,
    ) {
      List<Map<String, Object>> palettes = option.resolvedPalettes.map((
        KBPaletteOption palette,
      ) {
        String? bodyClass = palette.bodyClass ?? palette.stylesheet.bodyClass;
        Map<String, Object> entry = <String, Object>{
          'id': palette.id,
          'label': palette.label,
        };
        if (bodyClass != null) {
          entry['bodyClass'] = bodyClass;
        }
        if (palette.swatch != null) {
          entry['swatch'] = palette.swatch!;
        }
        return entry;
      }).toList();
      Map<String, Object> json = <String, Object>{
        'id': option.id,
        'label': option.label,
        'palettes': palettes,
      };
      if (palettes.isNotEmpty) {
        json['defaultPaletteId'] = palettes.first['id']!;
      }
      if (option.stylesheet.bodyClass != null) {
        json['bodyClass'] = option.stylesheet.bodyClass!;
      }
      return json;
    }).toList();
    return jsonEncode(options);
  }

  String _fallbackStylesheetId() {
    if (defaultStylesheetId.isNotEmpty) {
      return defaultStylesheetId;
    }
    if (stylesheetOptions.isEmpty) {
      // Single-stylesheet apps render one synthesized slot with id 'default';
      // the client must select it so the slot stays visible.
      return 'default';
    }
    return stylesheetOptions.first.id;
  }

  String _searchFunctionality() =>
      '''
// ===== SEARCH FUNCTIONALITY =====
(function() {
  if (window.__kbSearchInitialized) return;
  window.__kbSearchInitialized = true;

  var basePath = '$basePath';
  var searchState = new WeakMap();
  var nextSearchResultsId = 0;

  function activeScopeFor(input) {
    return input.closest('[data-kb-style-slot]') || getActiveKbSlot();
  }

  function resultsForInput(input) {
    var search = input.closest('[data-kb-search]');
    return search ? search.querySelector('[data-kb-search-results], .search-results') : null;
  }

  function commandDrawerForInput(input) {
    return input.closest('[data-kb-command-drawer]');
  }

  function openCommandDrawer(input) {
    var drawer = commandDrawerForInput(input);
    if (drawer) drawer.open = true;
  }

  function closeCommandDrawer(input) {
    var drawer = commandDrawerForInput(input);
    if (drawer) drawer.open = false;
  }

  function closeOpenCommandDrawers(scope) {
    var closed = false;
    scope.querySelectorAll('[data-kb-command-drawer][open]').forEach(function(drawer) {
      drawer.open = false;
      closed = true;
    });
    return closed;
  }

  function buildSearchIndex(scope) {
    var searchIndex = [];
    scope.querySelectorAll('.sidebar-link').forEach(function(link) {
      var text = link.textContent.trim();
      var href = link.getAttribute('href');
      if (text && href) {
        var parts = href.split('/');
        var category = parts.length > 1 ? parts[1] : '';
        category = category.charAt(0).toUpperCase() + category.slice(1).replace(/-/g, ' ');
        searchIndex.push({
          title: text,
          href: href,
          category: category,
          searchText: text.toLowerCase()
        });
      }
    });
    return searchIndex;
  }

  function stateForInput(input) {
    var state = searchState.get(input);
    if (!state) {
      state = {
        selectedIndex: -1,
        currentResults: [],
        searchIndex: buildSearchIndex(activeScopeFor(input))
      };
      searchState.set(input, state);
    }
    return state;
  }

  function refreshState(input) {
    var state = stateForInput(input);
    state.searchIndex = buildSearchIndex(activeScopeFor(input));
    return state;
  }

  function filterSearchResults(state, query) {
    return state.searchIndex.filter(function(item) {
      return item.searchText.includes(query);
    }).slice(0, ${KBScriptConfig.maxSearchResults});
  }

  function updateHighlight(input) {
    var searchResults = resultsForInput(input);
    var state = stateForInput(input);
    if (!searchResults) return;
    var items = searchResults.querySelectorAll('a[data-index]');
    items.forEach(function(item, i) {
      var selected = i === state.selectedIndex;
      item.classList.toggle('is-selected', selected);
      item.setAttribute('aria-selected', selected ? 'true' : 'false');
      if (selected) {
        item.scrollIntoView({ block: 'nearest' });
      }
    });
  }

  function showResults(input, results) {
    var searchResults = resultsForInput(input);
    var state = stateForInput(input);
    if (!searchResults) return;
    state.currentResults = results;
    state.selectedIndex = -1;
    searchResults.replaceChildren();
    searchResults.hidden = false;
    searchResults.style.display = 'block';
    input.setAttribute('aria-expanded', 'true');
    if (results.length === 0) {
      var empty = document.createElement('div');
      empty.className = 'kb-search-empty';
      empty.setAttribute('role', 'status');
      empty.textContent = 'No results found';
      searchResults.appendChild(empty);
      return;
    }

    results.forEach(function(item, index) {
      var fullHref = basePath + item.href;
      var link = document.createElement('a');
      link.className = 'kb-search-result';
      link.href = fullHref;
      link.dataset.index = String(index);
      link.setAttribute('role', 'option');
      link.setAttribute('aria-selected', 'false');

      var title = document.createElement('div');
      title.className = 'kb-search-result-title';
      title.textContent = item.title;
      link.appendChild(title);

      var category = document.createElement('div');
      category.className = 'kb-search-result-category';
      category.textContent = item.category;
      link.appendChild(category);

      link.addEventListener('mouseenter', function() {
        state.selectedIndex = parseInt(this.dataset.index, 10);
        updateHighlight(input);
      });
      searchResults.appendChild(link);
    });
  }

  function hideResults(input) {
    var searchResults = resultsForInput(input);
    var state = stateForInput(input);
    if (!searchResults) return;
    searchResults.style.display = 'none';
    searchResults.hidden = true;
    input.setAttribute('aria-expanded', 'false');
    state.selectedIndex = -1;
    state.currentResults = [];
  }

  function isResultsVisible(input) {
    var searchResults = resultsForInput(input);
    return !!searchResults && !searchResults.hidden;
  }

  function navigateToSelected(input) {
    var state = stateForInput(input);
    if (state.selectedIndex >= 0 && state.selectedIndex < state.currentResults.length) {
      var href = basePath + state.currentResults[state.selectedIndex].href;
      if (window.__kbNavigateTo) {
        window.__kbNavigateTo(href);
      } else {
        window.location.href = href;
      }
    }
  }

  function initializeInput(input) {
    var searchResults = resultsForInput(input);
    if (searchResults) {
      if (!searchResults.id) {
        nextSearchResultsId += 1;
        searchResults.id = 'kb-search-results-' + nextSearchResultsId;
      }
      input.setAttribute('aria-controls', searchResults.id);
    }
    if (input.getAttribute('data-kb-search-initialized') === 'true') return;
    input.setAttribute('data-kb-search-initialized', 'true');
    input.setAttribute('aria-expanded', 'false');

    input.addEventListener('input', function() {
      var state = refreshState(this);
      var query = this.value.toLowerCase().trim();
      if (query.length < ${KBScriptConfig.minSearchQueryLength}) {
        hideResults(this);
        return;
      }
      showResults(this, filterSearchResults(state, query));
    });

    input.addEventListener('focus', function() {
      var state = refreshState(this);
      if (this.value.length >= ${KBScriptConfig.minSearchQueryLength}) {
        showResults(this, filterSearchResults(state, this.value.toLowerCase().trim()));
      }
    });

    input.addEventListener('blur', function() {
      var currentInput = this;
      setTimeout(function() {
        var searchResults = resultsForInput(currentInput);
        if (!searchResults || !searchResults.contains(document.activeElement)) {
          hideResults(currentInput);
        }
      }, 150);
    });

    input.addEventListener('keydown', function(e) {
      var key = e.key;
      var state = stateForInput(this);

      if (key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        hideResults(this);
        closeCommandDrawer(this);
        this.blur();
        return;
      }

      if (!isResultsVisible(this)) return;

      if (key === 'ArrowDown') {
        e.preventDefault();
        e.stopPropagation();
        if (state.currentResults.length > 0) {
          state.selectedIndex = Math.min(state.selectedIndex + 1, state.currentResults.length - 1);
          updateHighlight(this);
        }
      } else if (key === 'ArrowUp') {
        e.preventDefault();
        e.stopPropagation();
        if (state.currentResults.length > 0) {
          state.selectedIndex = Math.max(state.selectedIndex - 1, -1);
          updateHighlight(this);
        }
      } else if (key === 'Enter') {
        e.preventDefault();
        e.stopPropagation();
        if (state.selectedIndex >= 0) {
          navigateToSelected(this);
        } else if (state.currentResults.length > 0) {
          state.selectedIndex = 0;
          navigateToSelected(this);
        }
      }
    }, true);
  }

  function initializeSearchInputs() {
    document.querySelectorAll('[data-kb-search-input], #kb-search').forEach(initializeInput);
  }

  document.addEventListener('click', function(e) {
    var target = e.target;
    document.querySelectorAll('[data-kb-search-input], #kb-search').forEach(function(input) {
      var searchResults = resultsForInput(input);
      var clickedInsideSearch = input === target || input.contains(target);
      var clickedInsideResults = searchResults && (searchResults === target || searchResults.contains(target));
      if (!clickedInsideSearch && !clickedInsideResults && isResultsVisible(input)) {
        hideResults(input);
        input.blur();
      }
    });
  }, true);

  document.addEventListener('keydown', function(e) {
    var key = e.key;

    if (key === 'Escape') {
      var activeScope = getActiveKbSlot();
      var closedDrawer = closeOpenCommandDrawers(activeScope);
      document.querySelectorAll('[data-kb-search-input], #kb-search').forEach(function(input) {
        if (isResultsVisible(input)) {
          e.preventDefault();
          e.stopPropagation();
          hideResults(input);
          closeCommandDrawer(input);
          input.blur();
        }
      });
      if (closedDrawer) {
        e.preventDefault();
        e.stopPropagation();
      }
    }

    if ((e.metaKey || e.ctrlKey) && key.toLowerCase() === 'k') {
      e.preventDefault();
      e.stopPropagation();
      var scope = getActiveKbSlot();
      var input = scope.querySelector('[data-kb-command-drawer] [data-kb-search-input], [data-kb-command-drawer] #kb-search');
      if (!input) {
        input = scope.querySelector('[data-kb-search-input], #kb-search');
      }
      if (input) {
        openCommandDrawer(input);
        input.focus();
        input.select();
      }
    }
  }, true);

  initializeSearchInputs();
  window.__kbInitializeSearch = initializeSearchInputs;
  window.addEventListener('arcane-style-change', initializeSearchInputs);
})();
''';

  String _softNavigation() =>
      '''
(function() {
  if (window.__kbSoftNavigationInitialized) return;
  window.__kbSoftNavigationInitialized = true;

  var basePath = '$basePath';
  var normalizedBasePath = basePath || '';
  if (normalizedBasePath.length > 1 && normalizedBasePath.endsWith('/')) {
    normalizedBasePath = normalizedBasePath.substring(0, normalizedBasePath.length - 1);
  }
  if (normalizedBasePath === '/') {
    normalizedBasePath = '';
  }
  var requestToken = 0;
  var renderedHref = window.location.href;
  var homePath = normalizePath(normalizedBasePath || '/');

  function normalizePath(path) {
    if (!path) return '/';
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  function shouldHandleSoftNav(link) {
    if (!link || !link.closest) return false;
    if (link.getAttribute('data-kb-hard-nav') === 'true') return false;
    if (!link.closest('.kb-page-shell')) return false;
    return true;
  }

  function containsJasprClientIslands(pageDocument) {
    if (!pageDocument.body) return false;
    var comments = pageDocument.createTreeWalker(
      pageDocument.body,
      NodeFilter.SHOW_COMMENT,
    );
    var comment;
    while ((comment = comments.nextNode())) {
      if (comment.data.trim().startsWith('@')) return true;
    }
    return false;
  }

  function isNavigableUrl(url) {
    if (url.origin !== window.location.origin) return false;
    if (url.protocol !== 'http:' && url.protocol !== 'https:') return false;
    if (normalizedBasePath &&
        url.pathname !== normalizedBasePath &&
        url.pathname.indexOf(normalizedBasePath + '/') !== 0) {
      return false;
    }
    return true;
  }

  function updateSidebarActive(pathname) {
    var targetPath = normalizePath(pathname);
    document.querySelectorAll('.sidebar-link').forEach(function(link) {
      try {
        var linkUrl = new URL(link.href, window.location.origin);
        var linkPath = normalizePath(linkUrl.pathname);
        link.classList.toggle('active', linkPath === targetPath);
      } catch (_) {}
    });
  }

  function updateTopBarActive(pathname) {
    var targetPath = normalizePath(pathname);
    document.querySelectorAll('.kb-topbar-link').forEach(function(link) {
      if (link.getAttribute('target') === '_blank') return;
      try {
        var linkUrl = new URL(link.href, window.location.origin);
        var linkPath = normalizePath(linkUrl.pathname);
        var isRootLink = linkPath === homePath;
        var isActive = isRootLink
            ? targetPath === linkPath
            : targetPath === linkPath || targetPath.indexOf(linkPath + '/') === 0;
        link.classList.toggle('active', isActive);
      } catch (_) {}
    });
  }

  function replaceStyleSlots(nextDocument) {
    var nextSlots = nextDocument.querySelectorAll('[data-kb-style-slot]');
    var currentSlots = document.querySelectorAll('[data-kb-style-slot]');
    if (nextSlots.length && currentSlots.length === nextSlots.length) {
      for (var i = 0; i < currentSlots.length; i++) {
        currentSlots[i].replaceWith(nextSlots[i]);
      }
      updateStylesheetClasses();
      updateStylesheetSelect(getCurrentStylesheetId());
      updatePaletteSelect(getCurrentStylesheetId(), getCurrentPaletteId(getCurrentStylesheetId()));
      if (window.__kbApplySidebarCollapseState) {
        window.__kbApplySidebarCollapseState();
      }
      return true;
    }
    return false;
  }

  function navigateTo(href, pushHistory) {
    var destination = new URL(href, window.location.origin);
    if (!isNavigableUrl(destination)) {
      window.location.assign(destination.href);
      return;
    }

    var current = new URL(renderedHref);
    var destinationPath = normalizePath(destination.pathname);
    var currentPath = normalizePath(current.pathname);

    if (destinationPath === currentPath && destination.search === current.search) {
      if (destination.hash) {
        if (pushHistory && destination.href !== window.location.href) {
          history.pushState({ href: destination.href }, '', destination.href);
        }
        var hashId = destination.hash.substring(1);
        try {
          hashId = decodeURIComponent(hashId);
        } catch (_) {}
        var hashTarget = document.getElementById(hashId);
        if (hashTarget) {
          hashTarget.scrollIntoView({ behavior: 'smooth', block: 'start' });
          if (window.__kbInitializePage) {
            window.__kbInitializePage();
          }
        } else {
          window.location.hash = destination.hash;
        }
      } else if (pushHistory && destination.href !== window.location.href) {
        history.pushState({ href: destination.href }, '', destination.href);
      }
      renderedHref = destination.href;
      return;
    }

    if (containsJasprClientIslands(document)) {
      window.location.assign(destination.href);
      return;
    }

    var token = ++requestToken;
    fetch(destination.href, { credentials: 'same-origin' })
      .then(function(response) {
        if (!response.ok) throw new Error('navigation_failed');
        return response.text();
      })
      .then(function(html) {
        if (token !== requestToken) return;

        var parser = new DOMParser();
        var nextDocument = parser.parseFromString(html, 'text/html');
        if (containsJasprClientIslands(nextDocument)) {
          window.location.assign(destination.href);
          return;
        }
        if (!replaceStyleSlots(nextDocument)) {
          var nextMainArea = nextDocument.querySelector('.kb-main-area');
          var currentMainArea = document.querySelector('.kb-main-area');
          if (!nextMainArea || !currentMainArea) {
            window.location.assign(destination.href);
            return;
          }
          currentMainArea.replaceWith(nextMainArea);
        }

        var currentMainArea = getActiveKbSlot().querySelector('.kb-main-area');
        if (!currentMainArea) {
          window.location.assign(destination.href);
          return;
        }
        updateSidebarActive(destination.pathname);
        updateTopBarActive(destination.pathname);

        if (nextDocument.title) {
          document.title = nextDocument.title;
        }

        var nextDescription = nextDocument.querySelector('meta[name="description"]');
        var currentDescription = document.querySelector('meta[name="description"]');
        if (nextDescription && currentDescription) {
          currentDescription.setAttribute(
            'content',
            nextDescription.getAttribute('content') || '',
          );
        } else if (nextDescription && !currentDescription) {
          document.head.appendChild(nextDescription.cloneNode(true));
        }

        if (pushHistory) {
          history.pushState({ href: destination.href }, '', destination.href);
        }
        renderedHref = destination.href;

        if (!destination.hash) {
          window.scrollTo({ top: 0, behavior: 'auto' });
        } else {
          var anchorTarget = document.getElementById(destination.hash.substring(1));
          if (anchorTarget) {
            anchorTarget.scrollIntoView();
          } else {
            window.location.hash = destination.hash;
          }
        }

        if (window.__kbInitializePage) {
          window.__kbInitializePage();
        }
        if (window.__kbInitializeSearch) {
          window.__kbInitializeSearch();
        }
        if (window.__kbInitializeSidebarChrome) {
          window.__kbInitializeSidebarChrome();
        }
      })
      .catch(function() {
        window.location.assign(destination.href);
      });
  }

  window.__kbNavigateTo = function(href) {
    navigateTo(href, true);
  };

  document.addEventListener('click', function(e) {
    if (e.defaultPrevented) return;
    if (e.button !== 0) return;
    if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;

    var target = e.target;
    if (!target || !target.closest) return;

    var link = target.closest('a[href]');
    if (!link) return;
    if (!shouldHandleSoftNav(link)) return;
    if (link.hasAttribute('download')) return;

    var targetAttr = link.getAttribute('target');
    if (targetAttr && targetAttr !== '_self') return;

    var href = link.getAttribute('href');
    if (!href || href.startsWith('javascript:')) return;

    if (href.startsWith('#')) {
      e.preventDefault();
      navigateTo(window.location.pathname + window.location.search + href, true);
      return;
    }

    var destination = new URL(href, window.location.origin);
    if (!isNavigableUrl(destination)) return;

    e.preventDefault();
    navigateTo(destination.href, true);
  }, true);

  window.addEventListener('popstate', function() {
    navigateTo(window.location.href, false);
  });
})();
''';

  static String _codeBlockCopyButtons() =>
      '''
// ===== CODE BLOCK COPY BUTTONS =====
var copyIconSvg = '${KBIcons.copy}';
var checkIconSvg = '${KBIcons.check}';

var proseBlocks = document.querySelectorAll('.prose pre');
proseBlocks.forEach(function(pre) {
  if (pre.parentNode.classList.contains('code-block-wrapper')) return;
  if (pre.closest('.arcane-code-block')) return;

  var wrapper = document.createElement('div');
  wrapper.className = 'code-block-wrapper';
  pre.parentNode.insertBefore(wrapper, pre);
  wrapper.appendChild(pre);
  pre.style.paddingRight = '50px';

  var copyBtn = document.createElement('button');
  copyBtn.className = 'copy-code-btn';
  copyBtn.setAttribute('type', 'button');
  copyBtn.setAttribute('aria-label', 'Copy code');
  copyBtn.setAttribute('title', 'Copy code');
  copyBtn.setAttribute('aria-live', 'polite');
  copyBtn.innerHTML = copyIconSvg;
  wrapper.appendChild(copyBtn);

  copyBtn.onclick = function(e) {
    e.preventDefault();
    e.stopPropagation();
    var btn = this;
    var codeEl = pre.querySelector('code') || pre;
    var text = codeEl.textContent || '';

    navigator.clipboard.writeText(text).then(function() {
      btn.innerHTML = checkIconSvg;
      btn.classList.add('copied');
      btn.setAttribute('aria-label', 'Copied');
      setTimeout(function() {
        btn.innerHTML = copyIconSvg;
        btn.classList.remove('copied');
        btn.setAttribute('aria-label', 'Copy code');
      }, ${KBScriptConfig.copyFeedbackTimeout});
    }).catch(function() {
      var textarea = document.createElement('textarea');
      textarea.value = text;
      textarea.style.position = 'fixed';
      textarea.style.opacity = '0';
      document.body.appendChild(textarea);
      textarea.select();
      try {
        document.execCommand('copy');
        btn.innerHTML = checkIconSvg;
        btn.classList.add('copied');
        btn.setAttribute('aria-label', 'Copied');
        setTimeout(function() {
          btn.innerHTML = copyIconSvg;
          btn.classList.remove('copied');
          btn.setAttribute('aria-label', 'Copy code');
        }, ${KBScriptConfig.copyFeedbackTimeout});
      } catch(e) {}
      document.body.removeChild(textarea);
    });
  };
});
''';

  static String _syntaxHighlighting() => '''
// ===== SYNTAX HIGHLIGHTING =====
(function() {
  if (window.__kbSyntaxHighlightInitialized) return;
  window.__kbSyntaxHighlightInitialized = true;

  var maxRetries = 30;
  var retryDelayMs = 60;
  var highlightAttribute = 'data-kb-highlighted';
  var languageClasses = ['dart', 'javascript', 'yaml', 'bash', 'json', 'html', 'css'];

  function hasLanguageClass(className) {
    if (!className) return false;
    return className.split(' ').some(function(token) {
      return token === 'language-dart' ||
             token === 'language-javascript' ||
             token === 'language-yaml' ||
             token === 'language-bash' ||
             token === 'language-json' ||
             token === 'language-html' ||
             token === 'language-css' ||
             token === 'language-js' ||
             token === 'language-shell' ||
             token === 'language-sh';
    });
  }

  function normalizeLanguageClasses(block) {
    if (block.getAttribute(highlightAttribute) === '1') return;
    var className = block.className || '';
    if (!hasLanguageClass(className) &&
        className.indexOf('language-') === -1) {
      block.classList.add('language-dart');
      return;
    }
    if (!hasLanguageClass(className) && className.indexOf('language-') !== -1) {
      var classes = className.trim().split(/\\s+/);
      var languageClass = null;
      for (var i = 0; i < classes.length; i++) {
        if (classes[i].indexOf('language-') === 0) {
          languageClass = classes[i];
          break;
        }
      }
      if (!languageClass) return;
      if (languageClass === 'language-js' || languageClass === 'language-shell') {
        block.classList.remove(languageClass);
        block.classList.add(languageClass.replace('language-js', 'language-javascript'));
      }
    }
  }

  function highlight() {
    if (typeof hljs === 'undefined' || typeof hljs.highlightElement !== 'function') {
      return false;
    }

    hljs.configure({
      ignoreUnescapedHTML: true,
      languages: languageClasses,
    });

    document.querySelectorAll('pre code').forEach(function(block) {
      normalizeLanguageClasses(block);
      if (block.getAttribute(highlightAttribute) === '1') return;
      if (block.className.indexOf('hljs-') !== -1) return;
      hljs.highlightElement(block);
      block.setAttribute(highlightAttribute, '1');
    });

    return true;
  }

  function initWithRetry(retriesLeft) {
    if (highlight()) return;
    if (retriesLeft <= 0) return;
    window.setTimeout(function() {
      initWithRetry(retriesLeft - 1);
    }, retryDelayMs);
  }

  function observeDynamicCodeBlocks() {
    if (window.__kbSyntaxHighlightObserver || !window.MutationObserver) return;
    window.__kbSyntaxHighlightObserver = new MutationObserver(function() {
      highlight();
    });
    window.__kbSyntaxHighlightObserver.observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      initWithRetry(maxRetries);
      observeDynamicCodeBlocks();
    });
  } else {
    initWithRetry(maxRetries);
    observeDynamicCodeBlocks();
  }
})();
''';

  static String _mediaEmbeds() => '''
var mediaIframes = document.querySelectorAll('.kb-media-iframe iframe');
mediaIframes.forEach(function(frame) {
  if (!frame.getAttribute('loading')) frame.setAttribute('loading', 'lazy');
  if (!frame.getAttribute('referrerpolicy')) {
    frame.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
  }
});

var youtubeFrames = document.querySelectorAll('.kb-media-youtube iframe');
youtubeFrames.forEach(function(frame) {
  if (frame.getAttribute('data-kb-youtube-init') === '1') return;
  frame.setAttribute('data-kb-youtube-init', '1');
  frame.setAttribute('loading', 'eager');
  if (!frame.getAttribute('referrerpolicy')) {
    frame.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
  }

  var primarySrc = frame.getAttribute('data-kb-src') || frame.getAttribute('src') || '';
  var fallbackSrc = frame.getAttribute('data-kb-fallback-src') || '';
  var watchUrl = frame.getAttribute('data-kb-watch-url') || '';
  if (!frame.getAttribute('src') && primarySrc) {
    frame.setAttribute('src', primarySrc);
  }

  var settled = false;
  var timeoutHandle = null;
  var fallbackTried = false;

  function clearYoutubeTimeout() {
    if (timeoutHandle) {
      clearTimeout(timeoutHandle);
      timeoutHandle = null;
    }
  }

  function markReady() {
    if (settled) return;
    settled = true;
    clearYoutubeTimeout();
  }

  function scheduleTimeout() {
    clearYoutubeTimeout();
    timeoutHandle = setTimeout(onTimeout, 7000);
  }

  function showFallbackLink() {
    if (frame.getAttribute('data-kb-youtube-fallback') === '1') return;
    var fallback = document.createElement('a');
    fallback.href = watchUrl || primarySrc || fallbackSrc;
    fallback.target = '_blank';
    fallback.rel = 'noopener noreferrer';
    fallback.textContent = 'Open on YouTube';
    fallback.style.display = 'inline-flex';
    fallback.style.marginTop = '0.5rem';
    fallback.style.fontSize = '0.875rem';
    fallback.style.textDecoration = 'underline';
    var container = frame.closest('.kb-media-youtube');
    if (container) {
      container.appendChild(fallback);
      frame.setAttribute('data-kb-youtube-fallback', '1');
    }
  }

  function onTimeout() {
    if (settled) return;
    if (!fallbackTried && fallbackSrc && frame.getAttribute('src') !== fallbackSrc) {
      fallbackTried = true;
      frame.setAttribute('src', fallbackSrc);
      scheduleTimeout();
      return;
    }
    settled = true;
    showFallbackLink();
  }

  frame.addEventListener('load', markReady);
  scheduleTimeout();
});

var baseElement = document.querySelector('base[href]');
var baseHref = baseElement ? baseElement.getAttribute('href') || '/' : '/';
if (!baseHref.startsWith('/')) {
  baseHref = '/' + baseHref;
}
if (!baseHref.endsWith('/')) {
  baseHref = baseHref + '/';
}
var normalizedBase = baseHref === '/' ? '' : baseHref.replace(/\\/\$/, '');

function kbAbsoluteCandidate(path) {
  if (!normalizedBase) return path;
  if (!path.startsWith('/')) return path;
  return normalizedBase + path;
}

function kbVideoCandidates(src) {
  var value = (src || '').trim();
  if (!value) return [];
  if (/^(https?:|data:|blob:|\\/\\/)/i.test(value)) {
    return [value];
  }

  var candidates = [];
  function add(url) {
    if (!url) return;
    if (candidates.indexOf(url) === -1) candidates.push(url);
  }

  add(value);
  if (value.startsWith('/')) {
    add(kbAbsoluteCandidate(value));
  } else {
    var clean = value.replace(/^\\.\\//, '');
    add('/' + clean);
    add(kbAbsoluteCandidate('/' + clean));
    add('/assets/' + clean);
    add(kbAbsoluteCandidate('/assets/' + clean));
    add('/assets/videos/' + clean);
    add(kbAbsoluteCandidate('/assets/videos/' + clean));
    add('/videos/' + clean);
    add(kbAbsoluteCandidate('/videos/' + clean));
  }
  return candidates;
}

function kbInitLocalVideo(video) {
  if (video.getAttribute('data-kb-video-init') === '1') return;
  video.setAttribute('data-kb-video-init', '1');
  var source = video.querySelector('source');
  if (!source) return;

  var originalSrc = source.getAttribute('data-src') || source.getAttribute('src') || video.getAttribute('data-src') || '';
  var candidates = kbVideoCandidates(originalSrc);
  if (candidates.length === 0) return;

  var index = 0;
  var settled = false;

  function applyCurrent() {
    source.setAttribute('src', candidates[index]);
    video.load();
  }

  function complete() {
    settled = true;
    video.removeEventListener('error', onError);
    video.removeEventListener('loadeddata', onLoaded);
    video.removeEventListener('canplay', onLoaded);
  }

  function onLoaded() {
    if (settled) return;
    complete();
  }

  function onError() {
    if (settled) return;
    index += 1;
    if (index < candidates.length) {
      applyCurrent();
      return;
    }
    complete();
    var fallback = document.createElement('a');
    fallback.href = originalSrc;
    fallback.target = '_blank';
    fallback.rel = 'noopener noreferrer';
    fallback.textContent = 'Open video';
    fallback.style.display = 'inline-flex';
    fallback.style.marginTop = '0.5rem';
    fallback.style.fontSize = '0.875rem';
    fallback.style.textDecoration = 'underline';
    if (video.parentNode && video.parentNode.parentNode) {
      video.parentNode.parentNode.appendChild(fallback);
    }
  }

  video.addEventListener('error', onError);
  video.addEventListener('loadeddata', onLoaded);
  video.addEventListener('canplay', onLoaded);
  applyCurrent();
}

var localVideos = document.querySelectorAll('.kb-media-local video');
localVideos.forEach(kbInitLocalVideo);

var twitterContainers = document.querySelectorAll('.kb-media-twitter');
if (twitterContainers.length > 0) {
  if (!document.querySelector('script[src*="platform.twitter.com/widgets.js"]')) {
    var twitterScript = document.createElement('script');
    twitterScript.async = true;
    twitterScript.src = 'https://platform.twitter.com/widgets.js';
    twitterScript.charset = 'utf-8';
    document.body.appendChild(twitterScript);
  }

  if (window.__kbTwitterPollTimer) {
    clearInterval(window.__kbTwitterPollTimer);
    window.__kbTwitterPollTimer = null;
  }

  var tries = 0;
  window.__kbTwitterPollTimer = setInterval(function() {
    tries += 1;
    if (window.twttr && window.twttr.widgets && typeof window.twttr.widgets.load === 'function') {
      clearInterval(window.__kbTwitterPollTimer);
      window.__kbTwitterPollTimer = null;
      twitterContainers.forEach(function(container) {
        window.twttr.widgets.load(container);
      });
      return;
    }
    if (tries >= 60) {
      clearInterval(window.__kbTwitterPollTimer);
      window.__kbTwitterPollTimer = null;
      twitterContainers.forEach(function(container) {
        var link = container.querySelector('a[href*="twitter.com"], a[href*="x.com"]');
        if (!link) return;
        var href = link.getAttribute('href');
        if (!href) return;
        if (container.getAttribute('data-kb-twitter-fallback') === '1') return;
        var iframe = document.createElement('iframe');
        iframe.src = 'https://twitframe.com/show?url=' + encodeURIComponent(href);
        iframe.setAttribute('loading', 'lazy');
        iframe.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
        iframe.style.width = '100%';
        iframe.style.minHeight = '420px';
        iframe.style.border = '0';
        iframe.style.borderRadius = '8px';
        container.innerHTML = '';
        container.appendChild(iframe);
        container.setAttribute('data-kb-twitter-fallback', '1');
      });
    }
  }, 120);
}
''';

  static String _tocScrollTracking() => '''
// ===== TOC SCROLL TRACKING =====
if (window.__kbTocObserver) {
  window.__kbTocObserver.disconnect();
  window.__kbTocObserver = null;
}
if (window.__kbTocScrollHandler) {
  window.removeEventListener('scroll', window.__kbTocScrollHandler);
  window.__kbTocScrollHandler = null;
}

var tocScope = typeof getActiveKbSlot === 'function' ? getActiveKbSlot() : document;
var tocContainer = tocScope.querySelector('.toc-content');
if (tocContainer) {
  var tocLinks = tocContainer.querySelectorAll('a');
  var headings = [];

  tocLinks.forEach(function(link) {
    var href = link.getAttribute('href');
    if (href && href.startsWith('#')) {
      var id = href.slice(1);
      var heading = document.getElementById(id);
      if (heading) {
        headings.push({ id: id, element: heading, link: link });
      }
    }
  });

  if (headings.length > 0) {
    var currentActive = null;

    function updateActiveLink(activeId) {
      if (currentActive === activeId) return;
      currentActive = activeId;
      tocLinks.forEach(function(link) {
        var href = link.getAttribute('href');
        var isActive = href === '#' + activeId;
        link.classList.toggle('toc-active', isActive);
      });
    }

    var observerOptions = {
      root: null,
      rootMargin: '-80px 0px -70% 0px',
      threshold: 0
    };

    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          updateActiveLink(entry.target.id);
        }
      });
    }, observerOptions);
    window.__kbTocObserver = observer;

    headings.forEach(function(h) {
      observer.observe(h.element);
    });

    var scrollHandler = function() {
      if (window.scrollY < 100 && headings.length > 0) {
        updateActiveLink(headings[0].id);
      }
    };
    window.addEventListener('scroll', scrollHandler);
    window.__kbTocScrollHandler = scrollHandler;

    updateActiveLink(headings[0].id);
  }
}
''';

  static String _sidebarCollapse() => '''
// ===== SIDEBAR COLLAPSE =====
function getCollapseStorageKey(details) {
  var summarySpan = details.querySelector('summary span');
  if (!summarySpan || !summarySpan.textContent) return null;
  var label = summarySpan.textContent.trim();
  if (!label) return null;
  return 'kb-collapse-' + label;
}

window.__kbApplySidebarCollapseState = function() {
  document.querySelectorAll('.sidebar-details').forEach(function(details) {
    var key = getCollapseStorageKey(details);
    if (!key) return;
    var stored = localStorage.getItem(key);
    if (stored === 'closed') {
      details.removeAttribute('open');
    } else if (stored === 'open') {
      details.setAttribute('open', '');
    }
  });
};

if (!window.__kbSidebarInitialized) {
  window.__kbSidebarInitialized = true;

  document.addEventListener('toggle', function(e) {
    var details = e.target;
    if (!details || !details.classList || !details.classList.contains('sidebar-details')) {
      return;
    }
    var key = getCollapseStorageKey(details);
    if (!key) return;
    localStorage.setItem(key, details.open ? 'open' : 'closed');
  }, true);
}

function setSidebarOpen(scope, open, restoreFocus) {
  var sidebar = scope.querySelector('.kb-sidebar');
  if (!sidebar) return;
  if (!sidebar.id) {
    var slotId = scope.getAttribute('data-kb-style-slot') || 'default';
    sidebar.id = 'kb-sidebar-' + slotId;
  }
  var mobile = window.matchMedia('(max-width: 900px)').matches;
  var nextOpen = mobile && open;
  sidebar.classList.toggle('open', nextOpen);
  sidebar.setAttribute('aria-hidden', mobile && !nextOpen ? 'true' : 'false');
  if (mobile && !nextOpen) {
    sidebar.setAttribute('inert', '');
  } else {
    sidebar.removeAttribute('inert');
  }
  var toggles = scope.querySelectorAll('[data-kb-sidebar-toggle], .kb-hamburger');
  toggles.forEach(function(toggle) {
    toggle.setAttribute('aria-controls', sidebar.id);
    toggle.setAttribute('aria-expanded', nextOpen ? 'true' : 'false');
  });
  if (restoreFocus && !nextOpen && toggles.length > 0) {
    toggles[0].focus();
  }
}

window.__kbInitializeSidebarChrome = function() {
  document.querySelectorAll('[data-kb-sidebar-toggle], .kb-hamburger').forEach(function(hamburger) {
    if (hamburger.getAttribute('data-kb-sidebar-toggle-init') === 'true') return;
    hamburger.setAttribute('data-kb-sidebar-toggle-init', 'true');
    hamburger.setAttribute('aria-expanded', 'false');
    hamburger.addEventListener('click', function() {
      var scope = hamburger.closest('[data-kb-style-slot]') || getActiveKbSlot();
      var sidebar = scope.querySelector('.kb-sidebar');
      if (!sidebar) return;
      setSidebarOpen(scope, !sidebar.classList.contains('open'), false);
    });
  });
  document.querySelectorAll('.kb-sidebar').forEach(function(sidebar) {
    var scope = sidebar.closest('[data-kb-style-slot]') || getActiveKbSlot();
    setSidebarOpen(scope, sidebar.classList.contains('open'), false);
    if (sidebar.getAttribute('data-kb-sidebar-close-init') === 'true') return;
    sidebar.setAttribute('data-kb-sidebar-close-init', 'true');
    sidebar.addEventListener('click', function(e) {
      var target = e.target;
      if (!target || !target.closest || !target.closest('a')) return;
      if (window.matchMedia('(max-width: 900px)').matches) {
        setSidebarOpen(scope, false, false);
      }
    });
  });
};

if (!window.__kbSidebarDismissInitialized) {
  window.__kbSidebarDismissInitialized = true;
  document.addEventListener('keydown', function(e) {
    if (e.key !== 'Escape') return;
    var scope = getActiveKbSlot();
    var sidebar = scope.querySelector('.kb-sidebar.open');
    if (!sidebar) return;
    e.preventDefault();
    setSidebarOpen(scope, false, true);
  });
  document.addEventListener('click', function(e) {
    if (!window.matchMedia('(max-width: 900px)').matches) return;
    var target = e.target;
    if (!target || !target.closest) return;
    if (target.closest('.kb-sidebar, [data-kb-sidebar-toggle], .kb-hamburger')) return;
    var scope = getActiveKbSlot();
    if (scope.querySelector('.kb-sidebar.open')) {
      setSidebarOpen(scope, false, false);
    }
  });
  window.addEventListener('resize', function() {
    document.querySelectorAll('[data-kb-style-slot]').forEach(function(scope) {
      var sidebar = scope.querySelector('.kb-sidebar');
      if (sidebar) setSidebarOpen(scope, sidebar.classList.contains('open'), false);
    });
  });
}

window.__kbInitializeSidebarChrome();
window.__kbApplySidebarCollapseState();
''';

  static String _backToTop() => '''
// ===== BACK TO TOP =====
if (window.__kbBackToTopScrollHandler) {
  window.removeEventListener('scroll', window.__kbBackToTopScrollHandler);
  window.__kbBackToTopScrollHandler = null;
}
if (window.__kbBackToTopClickHandler && window.__kbBackToTopElement) {
  window.__kbBackToTopElement.removeEventListener('click', window.__kbBackToTopClickHandler);
  window.__kbBackToTopClickHandler = null;
  window.__kbBackToTopElement = null;
}

var backToTop = document.querySelector('.kb-back-to-top');
if (backToTop) {
  var scrollHandler = function() {
    if (window.scrollY > 300) {
      backToTop.classList.add('visible');
    } else {
      backToTop.classList.remove('visible');
    }
  };
  var clickHandler = function() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  window.addEventListener('scroll', scrollHandler);
  backToTop.addEventListener('click', clickHandler);
  window.__kbBackToTopScrollHandler = scrollHandler;
  window.__kbBackToTopClickHandler = clickHandler;
  window.__kbBackToTopElement = backToTop;
}
''';

  static String _topBarAutoHide() => '''
// ===== TOP BAR AUTO-HIDE =====
if (window.__kbTopBarAutoHideScrollHandler) {
  window.removeEventListener('scroll', window.__kbTopBarAutoHideScrollHandler);
  window.__kbTopBarAutoHideScrollHandler = null;
}

var autoHideTopBar = document.querySelector('.kb-topbar[data-kb-autohide="true"]');
if (autoHideTopBar) {
  var autoHideThreshold = 80;
  var autoHideLastY = window.scrollY || window.pageYOffset || 0;
  var autoHideTicking = false;

  var updateAutoHide = function() {
    autoHideTicking = false;
    var currentY = window.scrollY || window.pageYOffset || 0;
    if (currentY <= autoHideThreshold) {
      autoHideTopBar.classList.remove('kb-topbar--hidden');
    } else if (currentY > autoHideLastY) {
      autoHideTopBar.classList.add('kb-topbar--hidden');
    } else if (currentY < autoHideLastY) {
      autoHideTopBar.classList.remove('kb-topbar--hidden');
    }
    autoHideLastY = currentY;
  };

  var autoHideScrollHandler = function() {
    if (autoHideTicking) return;
    autoHideTicking = true;
    if (window.requestAnimationFrame) {
      window.requestAnimationFrame(updateAutoHide);
    } else {
      updateAutoHide();
    }
  };

  window.addEventListener('scroll', autoHideScrollHandler, { passive: true });
  window.__kbTopBarAutoHideScrollHandler = autoHideScrollHandler;
}
''';

  static String _ratingFunctionality() => '''
// ===== PAGE RATING =====
document.querySelectorAll('.kb-rating').forEach(function(ratingContainer) {
  if (ratingContainer.getAttribute('data-kb-rating-initialized') === 'true') return;
  ratingContainer.setAttribute('data-kb-rating-initialized', 'true');
  var ratingButtons = ratingContainer.querySelectorAll('.kb-rating-btn');
  var promptSection = ratingContainer.querySelector('.kb-rating-prompt');
  var thanksSection = ratingContainer.querySelector('.kb-rating-thanks');
  var pagePath = ratingContainer.dataset.path;

  // Check if user already rated this page
  var ratedKey = 'kb-rated-' + pagePath;
  if (localStorage.getItem(ratedKey)) {
    if (promptSection) promptSection.hidden = true;
    if (thanksSection) thanksSection.hidden = false;
  }

  ratingButtons.forEach(function(btn) {
    // Click handler
    btn.addEventListener('click', function() {
      var isHelpful = this.dataset.helpful === 'true';
      var path = this.dataset.path;

      // Mark as rated in localStorage to prevent duplicate votes
      localStorage.setItem(ratedKey, isHelpful ? 'helpful' : 'not-helpful');

      // Show thank you message
      if (promptSection) promptSection.hidden = true;
      if (thanksSection) thanksSection.hidden = false;

      // Dispatch custom event for Firebase integration
      // Your Firebase code can listen for this event:
      //
      // document.addEventListener('kb-rating', function(e) {
      //   var pagePath = e.detail.path;
      //   var isHelpful = e.detail.helpful;
      //   var docId = pagePath.replace(/\\//g, '_');
      //   var field = isHelpful ? 'helpful' : 'notHelpful';
      //
      //   firebase.firestore()
      //     .collection('pageRatings')
      //     .doc(docId)
      //     .set({
      //       [field]: firebase.firestore.FieldValue.increment(1),
      //       lastUpdated: firebase.firestore.FieldValue.serverTimestamp()
      //     }, { merge: true });
      // });

      document.dispatchEvent(new CustomEvent('kb-rating', {
        detail: {
          path: path,
          helpful: isHelpful
        }
      }));

    });
  });
});
''';
}
