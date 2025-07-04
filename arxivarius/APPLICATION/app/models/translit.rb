class Translit < ActiveRecord::Base

    def self.translate(str)

        #clean up first
        str.gsub!(/audiobook|\(abook\-club\.ru\)|\_rus/i, '')
        str.gsub!(/\(\s*\)/i, '')

        parts = str.split(/\-/)
        new_parts = []
        parts.each do |part|
            new_parts << translate_part(part)
        end

        str = new_parts.join(" - ")
        return str

    end

    def self.translate_part(str)
        str.strip!
        words = str.split(/\s+|\_|\./)
        new_words = []
        middle = false
        words.each do |word|
            word.strip!
            new_words << translate_word(word,middle)
            middle = true
        end
        return new_words.join(" ")
    end

    def self.translate_word(word, middle)
        word.downcase!
        db_trans = db_translate(word)
        return db_trans if !db_trans.nil?
        return alpha_translate(word, middle)
    end

    def self.db_translate(word)
        trans = Translit.find(:first, :conditions => ["LCASE(original) =  ?", word])
        return ((!trans.nil? && !trans.translated.empty?) ? trans.translated : nil)
    end

    def self.alpha_translate(word, middle)
        TRANSLIT_MAP.each do |ch,val|
            word.gsub!(/#{ch}/i, val)
        end
        word.gsub!(/\%20/,' ')
        return rus_up(word, middle)
    end

    def self.rus_up(word, middle)
        return word if (word == 'и' || word == 'к' || word == 'в'  || word == 'у') && middle
        first = word[0..0]
        first_new = CAP_MAP[first] || first
        word.sub!(/^./, first_new)
        return word
    end

    TRANSLIT_MAP = [
        ['sch', 'щ'],
        ['ch' , 'ч'],
        ['zh' , 'ж'],
        ['sh' , 'ш'],
        ['tz' , 'ц'],
        ['ya' , 'я'],
        ['yu' , 'ю'],
        ['ey' , 'ей'],
        ['ju' , 'ю'],
        ['ja' , 'я'],
        ['ia' , 'ия'],
        ['ei' , 'ей'],
        ['kiy', 'кий'],
        ['ky', 'кий'],

        ['a' , 'а'],
        ['b' , 'б'],
        ['c' , 'ц'],
        ['d' , 'д'],
        ['e' , 'е'],
        ['f' , 'ф'],
        ['g' , 'г'],
        ['h' , 'х'],
        ['i' , 'и'],
        ['j' , 'й'],
        ['k' , 'к'],
        ['l' , 'л'],
        ['m' , 'м'],
        ['n' , 'н'],
        ['o' , 'о'],
        ['p' , 'п'],
        ['r' , 'р'],
        ['s' , 'с'],
        ['t' , 'т'],
        ['u' , 'у'],
        ['v' , 'в'],
        ['w' , 'в'],
        ['x' , 'кс'],
        ['y' , 'ы'],
        ['z' , 'з'],
        ["'" , 'ь']

    ].freeze

    CAP_MAP = {
        'а' => 'А',
        'б' => 'Б',
        'в' => 'В',
        'г' => 'Г',
        'д' => 'Д',
        'е' => 'Е',
        'ё' => 'Ё',
        'ж' => 'Ж',
        'з' => 'З',
        'и' => 'И',
        'й' => 'Й',
        'к' => 'К',
        'л' => 'Л',
        'м' => 'М',
        'н' => 'Н',
        'о' => 'О',
        'п' => 'П',
        'р' => 'Р',
        'с' => 'С',
        'т' => 'Т',
        'у' => 'У',
        'ф' => 'Ф',
        'х' => 'Х',
        'ц' => 'Ц',
        'ч' => 'Ч',
        "ш" => 'Ш',
        "щ" => 'Щ',
        "ъ" => 'ъ',
        "ы" => 'Ы',
        "ь" => 'ь',
        "э" => 'Э',
        "ю" => 'Ю',
        "я" => 'Я'
    }.freeze

end
