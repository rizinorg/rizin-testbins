// dmd -O -g -of=elf/dlang_pet src/pets.d

interface Speaker {
    size_t speak();
}

interface Runner {
    size_t runSpeed();
}

interface Pet : Speaker, Runner {
    size_t petValue();
}

class BasePet : Pet {
    protected size_t value;

    this(size_t value) {
        this.value = value;
    }

    override size_t speak() {
        return value + 2;
    }

    override size_t runSpeed() {
        return value + 3;
    }

    override size_t petValue() {
        return value + 4;
    }

    size_t classValue() {
        return value + 5;
    }
}

class LoudPet : BasePet {
    this(size_t value) {
        super(value);
    }

    override size_t speak() {
        return value + 20;
    }

    override size_t petValue() {
        return value + 40;
    }

    override size_t classValue() {
        return value + 50;
    }
}

class Petoverr : BasePet, Speaker {
    this(size_t value) {
        super(value);
    }

    override size_t speak() {
        return value + 200;
    }
}

size_t dispatch(Speaker speaker, Runner runner, Pet pet, BasePet base) {
    size_t result = speaker.speak();
    result += runner.runSpeed();
    result += pet.petValue();
    result += base.classValue();
    return result;
}

void main() {
    auto base = new BasePet(10);
    auto loud = new LoudPet(10);
    auto petOverr = new Petoverr(10);

    assert(dispatch(base, base, base, base) == 54);
    assert(dispatch(loud, loud, loud, loud) == 153);
    assert(dispatch(petOverr, petOverr, petOverr, petOverr) == 252);
}
