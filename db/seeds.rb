require "json"

# ── Word puzzles ─────────────────────────────────────────────────────────────

word_puzzles = [
  # WORD SANDWICHES
  {
    category: "word_sandwich",
    difficulty: "easy",
    thinking_seconds: 25,
    question: "Which word goes after PAPER and before BONE?",
    answer: "BACK — PAPERBACK · BACKBONE"
  },
  {
    category: "word_sandwich",
    difficulty: "easy",
    thinking_seconds: 25,
    question: "Which word goes after SUN and before POT?",
    answer: "FLOWER — SUNFLOWER · FLOWERPOT"
  },
  {
    category: "word_sandwich",
    difficulty: "easy",
    thinking_seconds: 25,
    question: "Which word goes after BLACK and before CAGE?",
    answer: "BIRD — BLACKBIRD · BIRDCAGE"
  },
  {
    category: "word_sandwich",
    difficulty: "easy",
    thinking_seconds: 25,
    question: "Which word goes after BIRTH and before DREAM?",
    answer: "DAY — BIRTHDAY · DAYDREAM"
  },
  {
    category: "word_sandwich",
    difficulty: "medium",
    thinking_seconds: 30,
    question: "Which word goes after HEAD and before AGE?",
    answer: "BAND — HEADBAND · BANDAGE"
  },
  {
    category: "word_sandwich",
    difficulty: "medium",
    thinking_seconds: 30,
    question: "Which word goes after HAND and before PIPE?",
    answer: "BAG — HANDBAG · BAGPIPE"
  },
  {
    category: "word_sandwich",
    difficulty: "medium",
    thinking_seconds: 30,
    question: "Which word goes after SEA and before STEP?",
    answer: "SIDE — SEASIDE · SIDESTEP"
  },
  {
    category: "word_sandwich",
    difficulty: "hard",
    thinking_seconds: 35,
    question: "Which word goes after FINGER and before OUT?",
    answer: "PRINT — FINGERPRINT · PRINTOUT"
  },
  # ODD ONE OUT
  {
    category: "odd_one_out",
    difficulty: "easy",
    thinking_seconds: 20,
    question: "Odd one out: JUPITER, MARS, SATURN, PLUTO",
    answer: "PLUTO — it's a dwarf planet, not a full planet (since 2006)"
  },
  {
    category: "odd_one_out",
    difficulty: "easy",
    thinking_seconds: 20,
    question: "Odd one out: VIOLIN, VIOLA, CELLO, FLUTE",
    answer: "FLUTE — the others are all string instruments"
  },
  {
    category: "odd_one_out",
    difficulty: "medium",
    thinking_seconds: 25,
    question: "Odd one out: APRIL, JUNE, SEPTEMBER, OCTOBER",
    answer: "OCTOBER — the others have 30 days; October has 31"
  },
  {
    category: "odd_one_out",
    difficulty: "medium",
    thinking_seconds: 25,
    question: "Odd one out: PACIFIC, ATLANTIC, INDIAN, CASPIAN",
    answer: "CASPIAN — it's a lake, not one of the world's oceans"
  },
  {
    category: "odd_one_out",
    difficulty: "hard",
    thinking_seconds: 30,
    question: "Odd one out: SPIDER, SCORPION, TICK, ANT",
    answer: "ANT — it's an insect (6 legs); the others are arachnids (8 legs)"
  },
  # DOUBLE DEFINITIONS
  {
    category: "double_definition",
    difficulty: "easy",
    thinking_seconds: 25,
    question: "One word, two meanings: where you save money / the edge of a river",
    answer: "BANK"
  },
  {
    category: "double_definition",
    difficulty: "easy",
    thinking_seconds: 25,
    question: "One word, two meanings: a precious stone / a baseball playing field",
    answer: "DIAMOND"
  },
  {
    category: "double_definition",
    difficulty: "easy",
    thinking_seconds: 20,
    question: "One word, two meanings: a bird / zero runs in cricket",
    answer: "DUCK"
  },
  {
    category: "double_definition",
    difficulty: "medium",
    thinking_seconds: 25,
    question: "One word, two meanings: a season / a sudden jump",
    answer: "SPRING"
  },
  {
    category: "double_definition",
    difficulty: "medium",
    thinking_seconds: 30,
    question: "One word, two meanings: the underside of a shoe / a type of flatfish",
    answer: "SOLE"
  },
  {
    category: "double_definition",
    difficulty: "hard",
    thinking_seconds: 30,
    question: "One word, two meanings: to desert someone / a drainage channel",
    answer: "DITCH"
  },
  # LETTER EQUATIONS
  {
    category: "letter_equation",
    difficulty: "easy",
    thinking_seconds: 20,
    question: "7 = D of the W",
    answer: "Days of the Week"
  },
  {
    category: "letter_equation",
    difficulty: "easy",
    thinking_seconds: 20,
    question: "12 = M in a Y",
    answer: "Months in a Year"
  },
  {
    category: "letter_equation",
    difficulty: "medium",
    thinking_seconds: 25,
    question: "88 = K on a P",
    answer: "Keys on a Piano"
  },
  {
    category: "letter_equation",
    difficulty: "medium",
    thinking_seconds: 25,
    question: "64 = S on a CB",
    answer: "Squares on a Chessboard"
  },
  {
    category: "letter_equation",
    difficulty: "medium",
    thinking_seconds: 25,
    question: "11 = P in a FT",
    answer: "Players in a Football Team"
  },
  {
    category: "letter_equation",
    difficulty: "hard",
    thinking_seconds: 30,
    question: "360 = D in a C",
    answer: "Degrees in a Circle"
  },
  {
    category: "letter_equation",
    difficulty: "hard",
    thinking_seconds: 30,
    question: "52 = W in a Y",
    answer: "Weeks in a Year"
  },
  {
    category: "letter_equation",
    difficulty: "hard",
    thinking_seconds: 35,
    question: "1001 = AN",
    answer: "1001 Arabian Nights"
  }
]

word_puzzles.each do |attrs|
  Riddle.find_or_create_by!(question: attrs[:question]) do |r|
    r.assign_attributes(attrs.merge(published: true))
  end
end

# ── Cryptic clues — bulk-loaded from db/cryptic_clues.json ───────────────────
# Generated by scripts/fetch-cryptic-clues.mjs from cryptics.georgeho.org

cryptic_path = Rails.root.join("db", "cryptic_clues.json")

if File.exist?(cryptic_path)
  cryptic_clues = JSON.parse(File.read(cryptic_path))

  # Skip any clues already in the database to keep re-runs idempotent
  existing = Riddle.where(category: "cryptic").pluck(:question).to_set

  now = Time.current
  rows = cryptic_clues
    .reject { |c| existing.include?(c["clue"]) }
    .map do |c|
      difficulty = case c["letterCount"]
                   when 3..4 then "easy"
                   when 5..6 then "medium"
                   else           "hard"
                   end
      {
        question:        c["clue"],
        answer:          c["answer"].downcase.capitalize,
        category:        "cryptic",
        difficulty:      difficulty,
        thinking_seconds: 45,
        published:       true,
        created_at:      now,
        updated_at:      now
      }
    end

  Riddle.insert_all(rows) if rows.any?
  puts "Loaded #{cryptic_clues.size} cryptic clues (#{rows.size} new) from #{cryptic_path}"
else
  puts "Skipping cryptic clues — db/cryptic_clues.json not found (run: node scripts/fetch-cryptic-clues.mjs)"
end

# ── Summary ───────────────────────────────────────────────────────────────────

by_type = Riddle.group(:category).count
puts "Seeded #{Riddle.count} puzzles total:"
by_type.each { |type, n| puts "  #{type}: #{n}" }
