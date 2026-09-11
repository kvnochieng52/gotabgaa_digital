<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('programs', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('host');
            $table->enum('type', ['tv', 'radio']);
            $table->enum('day', ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']);
            $table->string('start_time', 5); // HH:MM
            $table->string('end_time', 5);
            $table->string('image')->nullable();
            $table->boolean('active')->default(true);
            $table->timestamps();

            $table->index(['type', 'day', 'start_time']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('programs');
    }
};
