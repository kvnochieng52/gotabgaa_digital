<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('polls', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('question');
            $table->json('options'); // [{id, label, votes}]
            $table->boolean('active')->default(true);
            $table->timestamp('closes_at')->nullable();
            $table->timestamps();

            $table->index('active');
        });

        Schema::create('poll_votes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('poll_id')->constrained('polls')->cascadeOnDelete();
            $table->string('option_id');
            $table->string('voter_fingerprint', 64); // hash of IP+UA
            $table->timestamp('voted_at')->useCurrent();

            $table->unique(['poll_id', 'voter_fingerprint']);
            $table->index(['poll_id', 'option_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('poll_votes');
        Schema::dropIfExists('polls');
    }
};
