<?php

namespace App\Filament\Resources\Articles\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class ArticlesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')->square()->size(56),
                TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->limit(60)
                    ->weight('bold'),
                TextColumn::make('category.name')
                    ->badge()
                    ->color('primary')
                    ->sortable(),
                TextColumn::make('author_name')
                    ->label('Author')
                    ->searchable(),
                IconColumn::make('featured')
                    ->boolean(),
                IconColumn::make('breaking')
                    ->boolean(),
                TextColumn::make('published_at')
                    ->dateTime('M j, Y g:i a')
                    ->sortable(),
                TextColumn::make('reading_time')
                    ->numeric()
                    ->suffix(' min')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('published_at', 'desc')
            ->filters([
                SelectFilter::make('category_id')
                    ->label('Category')
                    ->relationship('category', 'name'),
                TernaryFilter::make('featured'),
                TernaryFilter::make('breaking'),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
