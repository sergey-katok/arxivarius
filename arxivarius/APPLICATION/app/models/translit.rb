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
        return word if (word == '�' || word == '�' || word == '�'  || word == '�') && middle
        first = word[0..0]
        first_new = CAP_MAP[first] || first
        word.sub!(/^./, first_new)
        return word
    end

    TRANSLIT_MAP = [
        ['sch', '�'],
        ['ch' , '�'],
        ['zh' , '�'],
        ['sh' , '�'],
        ['tz' , '�'],
        ['ya' , '�'],
        ['yu' , '�'],
        ['ey' , '��'],
        ['ju' , '�'],
        ['ja' , '�'],
        ['ia' , '��'],
        ['ei' , '��'],
        ['kiy', '���'],
        ['ky', '���'],

        ['a' , '�'],
        ['b' , '�'],
        ['c' , '�'],
        ['d' , '�'],
        ['e' , '�'],
        ['f' , '�'],
        ['g' , '�'],
        ['h' , '�'],
        ['i' , '�'],
        ['j' , '�'],
        ['k' , '�'],
        ['l' , '�'],
        ['m' , '�'],
        ['n' , '�'],
        ['o' , '�'],
        ['p' , '�'],
        ['r' , '�'],
        ['s' , '�'],
        ['t' , '�'],
        ['u' , '�'],
        ['v' , '�'],
        ['w' , '�'],
        ['x' , '��'],
        ['y' , '�'],
        ['z' , '�'],
        ["'" , '�']

    ].freeze

    CAP_MAP = {
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        '�' => '�',
        "�" => '�',
        "�" => '�',
        "�" => '�',
        "�" => '�',
        "�" => '�',
        "�" => '�',
        "�" => '�',
        "�" => '�'
    }.freeze

end
