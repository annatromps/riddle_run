// scripts/fetch-cryptic-clues.mjs
// Downloads the cryptics dataset, filters for pure wordplay clues,
// and outputs a clean JSON file ready to import into the app.

import { writeFileSync, existsSync } from 'fs';
import { execSync } from 'child_process';

const DB_URL = 'https://cryptics.georgeho.org/data.db';
const DB_PATH = './cryptics.db';
const OUTPUT_PATH = './db/cryptic_clues.json';
const TARGET_COUNT = 500;

if (!existsSync(DB_PATH)) {
  console.log('Downloading cryptics database...');
  execSync(`curl -L -o ${DB_PATH} ${DB_URL}`, { stdio: 'inherit' });
} else {
  console.log('Using existing cryptics.db');
}

const ANAGRAM_INDICATORS = [
  'mixed', 'confused', 'wild', 'strange', 'odd', 'unusual', 'broken',
  'scrambled', 'jumbled', 'disordered', 'upset', 'troubled', 'changed',
  'altered', 'revised', 'converted', 'anagram', 'possibly', 'perhaps',
  'unusually', 'new', 'changing', 'composition', 'wildly', 'varied',
  'cooked', 'ruined', 'fresh', 'ordered', 'rearranged', 'shuffled'
];

const HIDDEN_INDICATORS = [
  'inside', 'within', 'hidden', 'found in', 'contained', 'partly',
  'some', 'in part', 'partially'
];

const REVERSAL_INDICATORS = [
  'back', 'returning', 'reversed', 'backward', 'going back', 'flipped',
  'turned', 'about'
];

const HOMOPHONE_INDICATORS = [
  'sounds like', 'we hear', 'reportedly', 'they say', 'audibly',
  'said to be', 'spoken'
];

const ALL_INDICATORS = [
  ...ANAGRAM_INDICATORS,
  ...HIDDEN_INDICATORS,
  ...REVERSAL_INDICATORS,
  ...HOMOPHONE_INDICATORS
];

// Use system sqlite3 CLI to fetch candidates
const query = `
  SELECT clue, answer
  FROM clues
  WHERE
    answer GLOB '[A-Z]*'
    AND answer NOT GLOB '*[^A-Z]*'
    AND length(answer) BETWEEN 3 AND 10
    AND clue IS NOT NULL
    AND clue != ''
  ORDER BY RANDOM()
  LIMIT 5000;
`.trim().replace(/\n\s+/g, ' ');

console.log('Querying database...');
const raw = execSync(`sqlite3 -json ${DB_PATH} "${query.replace(/"/g, '\\"')}"`, {
  maxBuffer: 50 * 1024 * 1024
}).toString();

const rows = JSON.parse(raw);
console.log(`Fetched ${rows.length} candidate clues from database`);

const seen = new Set();
const filtered = [];

for (const row of rows) {
  const clue = row.clue.toLowerCase();
  const answer = row.answer;

  if (seen.has(answer)) continue;
  if (answer.length > 9) continue;

  const hasIndicator = ALL_INDICATORS.some(ind => clue.includes(ind));
  if (!hasIndicator) continue;

  seen.add(answer);

  const letterCount = answer.length;
  const spokenClue = `${row.clue.replace(/\(\d+\)$/, '').trim()}. ${letterCount} letter${letterCount === 1 ? '' : 's'}.`;

  filtered.push({
    clue: `${row.clue.replace(/\(\d+\)$/, '').trim()} (${letterCount})`,
    answer: answer,
    letterCount: letterCount,
    spokenClue: spokenClue,
    spokenAnswer: `The answer is ${answer.toLowerCase()}. Spelled: ${answer.split('').join(', ')}.`
  });

  if (filtered.length >= TARGET_COUNT) break;
}

console.log(`Filtered down to ${filtered.length} clean clues`);

writeFileSync(OUTPUT_PATH, JSON.stringify(filtered, null, 2));
console.log(`Written to ${OUTPUT_PATH}`);

console.log('\nSample clues:');
filtered.slice(0, 5).forEach(c => {
  console.log(`  "${c.clue}" → ${c.answer}`);
});
